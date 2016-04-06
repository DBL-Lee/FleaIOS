//
//  PostItemTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import CoreLocation
import AWSCore
import AWSS3
import Alamofire
import SwiftyJSON

class PostItemTableViewController: UITableViewController {

    /*
    section0:
       row:
    ------------0-------------
        1照片:
        2标题:
        3价格:
        4类别:
        5位置:
        6数量:
    ------------7-------------
        8原价:
        9全新:
        10讲价:
        11延迟:
    ------------12------------
        13描述:
    
    
    
    */
    
    let 照片 = 1, 标题 = 2, 价格 = 3, 类别 = 4, 位置 = 5, 数量 = 6, 原价 = 8, 全新 = 9, 讲价 = 10, 置换 = 11, 描述 = 13
    var separator = [0,7,12]
    var images:[UIImage] = []
    var imagesUUID:[String] = []
    var imagesThumbnailUUID:[String] = []
    var mainIm = 0
    var staticCell:PostImageTableViewCell!
    var locale:NSLocale!
    var callback:()->Void = {}
    var uploading = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        
        self.tableView.registerNib(UINib(nibName: "PostImageTableViewCell", bundle: nil), forCellReuseIdentifier: "PostImageTableViewCell")
        self.tableView.registerNib(UINib(nibName: "EnterTextTableViewCell", bundle: nil), forCellReuseIdentifier: "EnterTextTableViewCell")
        self.tableView.registerNib(UINib(nibName: "DetailDisclosureTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailDisclosureTableViewCell")
        self.tableView.registerNib(UINib(nibName: "PostCounterTableViewCell", bundle: nil), forCellReuseIdentifier: "PostCounterTableViewCell")
        self.tableView.registerNib(UINib(nibName: "OptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "OptionsTableViewCell")
        self.tableView.registerNib(UINib(nibName: "PostDescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "PostDescriptionTableViewCell")
        self.tableView.keyboardDismissMode = .OnDrag
        
        staticCell = tableView.dequeueReusableCellWithIdentifier("PostImageTableViewCell") as! PostImageTableViewCell
        staticCell.width = self.view.frame.width
        staticCell.setImages([], deleteCallBack: deleteImageAtIndex, additionCallBack: takeAdditionalPhotos,tapHandler: presentPreviewVC)
        
        let temp = self.images
        self.images = []
        self.addImages(temp)
        
        //LoadingOverlay.shared.hideOverlayView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "发布商品"
        self.navigationItem.hidesBackButton = true
        let image = UIImage(named: "backButton.png")
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(PostItemTableViewController.dismiss), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }

    func setupUploadRequest(image:UIImage,thumbnailUUID:String? = nil)->AWSS3TransferManagerUploadRequest{
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        let fileName = thumbnailUUID == nil ? NSUUID().UUIDString+".png" : thumbnailUUID!
        let fileURL = LocalUploadDirectory.URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        let imageData = UIImagePNGRepresentation(image)
        imageData!.writeToFile(filePath, atomically: true)
        
        uploadRequest.bucket = S3ImagesBucketName
        uploadRequest.key = fileName
        uploadRequest.body = fileURL
        
        return uploadRequest
    }
    
    func deleteImageFromCloud(uuid:String){
        let deleteRequest = AWSS3DeleteObjectRequest()
        deleteRequest.bucket = S3ImagesBucketName
        deleteRequest.key = uuid
        
        AWSS3.defaultS3().deleteObject(deleteRequest)
    }

    func uploadImageToCloud(uploadRequest:AWSS3TransferManagerUploadRequest){
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        uploading += 1
        
        transferManager.upload(uploadRequest).continueWithBlock {
            task -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            break
                            
                        default:
                            print("upload() failed: [\(error)]")
                            break
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                    }
                } else {
                    print("upload() failed: [\(error)]")
                }
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
            }
            
            //upload complete
            if task.result != nil{
                self.uploading -= 1
                GLOBAL_imagesUUID.append(uploadRequest.key!)
            }
            return nil
        }
    }
    
    /*
    This is the add image callback of the camera/album class used to
    add the corresponding images
    */
    func addImages(images:[UIImage]){
        self.staticCell.addPhotos(images)
        self.images.appendContentsOf(images)
        for image in images{
            let uploadRequest = setupUploadRequest(image)
            uploadRequest.uploadProgress = {
                (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if totalBytesExpectedToSend > 0 {
                        self.staticCell.uploadPercentageChanged(self.images.indexOf(image)!, percentage: Int(100*Double(totalBytesSent) / Double(totalBytesExpectedToSend)))
                    }
                })
                
            }
            //create thumbnail and upload
            let thumbnailUUID = "small-"+uploadRequest.key!
            let uploadThumbnailRequest = setupUploadRequest(image.thumbnailOfSize(THUMBNAILSIZE),thumbnailUUID: thumbnailUUID)
            imagesThumbnailUUID.append(thumbnailUUID)
            uploadImageToCloud(uploadThumbnailRequest)
            
            imagesUUID.append(uploadRequest.key!)
            uploadImageToCloud(uploadRequest)
        }
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .None)
    }
    
    /*
    This is the change image callback of the image preview class
    */
    func changeMainIm(newId:Int){
        self.staticCell.changeMainIm(newId)
        self.mainIm = newId
    }
    
    /*
    This function is called when delete button is hit
    in the preview screen. It is just a wrapper of the 
    removeImageAtIndex function in cell class
    */
    func deleteFromPreview(id:Int){
        self.staticCell.removeImageAtIndex(id)
        
    }
    
    /*
    When removeImageAtIndex is called in cell class, this
    deletion call back is invoked first to delete the corresponding
    image in this viewcontroller.
    If the deleted image is the current main image, it changes the 
    main image to the first image before deleting the image.
    If the deleted image is before current main image, the record of
    current main image index is decremented.
    If the deleted image is the only and main image, the cell class
    still registers the first image as main image so that when later
    more images is added, it still sets the first image as main image
    */
    func deleteImageAtIndex(i:Int)->Bool{
        if uploading != 0{
            showUploadingAlert()
            return false
        }
        if i==mainIm{
            self.staticCell.changeMainIm(0)
        }
        if i<mainIm{
            mainIm -= 1
        }
        self.images.removeAtIndex(i)
        let uuid = self.imagesUUID.removeAtIndex(i)
        let thumbnailUUID = self.imagesThumbnailUUID.removeAtIndex(i)
        GLOBAL_imagesUUID.removeAtIndex(GLOBAL_imagesUUID.indexOf(uuid)!)
        GLOBAL_imagesUUID.removeAtIndex(GLOBAL_imagesUUID.indexOf(thumbnailUUID)!)
        deleteImageFromCloud(uuid)
        deleteImageFromCloud(thumbnailUUID)
        self.tableView.reloadData()
        return true
    }
    
    func takeAdditionalPhotos(){
        if uploading>0{
            showUploadingAlert()
        }else{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let camera = UIAlertAction(title: "使用相机", style: UIAlertActionStyle.Default, handler: {
                _ in
                self.showCamera()
            })
            let album = UIAlertAction(title: "使用相册", style: .Default, handler: {
                _ in
                self.showAlbum()
            })
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: {
                _ in
                alert.dismissViewControllerAnimated(true, completion: {})
            })
            alert.addAction(camera)
            alert.addAction(album)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: {})
        }
    }
    
    func showCamera(){
        let vc = PhotoCameraViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.callback = addImages
        vc.MAXPHOTO = GLOBAL_MAXIMUMPHOTO-self.images.count
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    func showAlbum(){
        let vc = PhotoAlbumViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.callback = addImages
        vc.MAXPHOTO = GLOBAL_MAXIMUMPHOTO-self.images.count
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    func presentPreviewVC(id:Int){
        if uploading>0{
            showUploadingAlert()
        }else{
            let vc = PostImagePreviewViewController()
            vc.im = images[id]
            vc.deleteImageCallBack = deleteFromPreview
            vc.id = id
            vc.mainImageCallBack = changeMainIm
            vc.mainTitleIsButton = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showUploadingAlert(){
        let alert = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        alert.textAlignment = .Center
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 8
        self.navigationController!.view.addSubview(alert)
        alert.center = self.navigationController!.view.center
        alert.backgroundColor = UIColor.blackColor()
        alert.textColor = UIColor.whiteColor()
        alert.text = "请等待图片上传结束"
        UIView.animateWithDuration(1, animations: {
            alert.alpha = 0
            }){
                success in
                if success {
                    alert.removeFromSuperview()
                }
        }
    }
    
    func dismiss(){
        GLOBAL_imagesUUID = []
        
        //delete uploaded images and thumbnails from cloud
        let remove = AWSS3Remove()
        var objectids = [AWSS3ObjectIdentifier]()
        for uuid in imagesUUID{
            let object = AWSS3ObjectIdentifier()
            object.key = uuid
            objectids.append(object)
        }
        for uuid in imagesThumbnailUUID{
            let object = AWSS3ObjectIdentifier()
            object.key = uuid
            objectids.append(object)
        }
        remove.objects = objectids
        
        
        let deleteRequest = AWSS3DeleteObjectsRequest()
        deleteRequest.bucket = S3ImagesBucketName
        deleteRequest.remove = remove
        
        AWSS3.defaultS3().deleteObjects(deleteRequest)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 照片:
            return staticCell
        case 标题:
            let cell = tableView.dequeueReusableCellWithIdentifier("EnterTextTableViewCell", forIndexPath: indexPath) as! EnterTextTableViewCell
            let title = "标题"
            let placeholder = "商品标题，最多20个字"
            let keyboard = UIKeyboardType.Default
            let limit = 20
            cell.setupCell(title,text:self.productTitle, placeholder: placeholder, keyboard: keyboard, limit: limit, callback:finishSettingTitle)
            return cell
        case 价格:
            let cell = tableView.dequeueReusableCellWithIdentifier("EnterTextTableViewCell", forIndexPath: indexPath) as! EnterTextTableViewCell
            let title = "价格"
            let placeholder = "想出售的价格"
            let keyboard = UIKeyboardType.DecimalPad
            let limit = 10
            cell.setupCell(title,text: self.currentPrice, placeholder: placeholder, keyboard: keyboard, limit: limit, callback: finishSettingPrice,rightAlign: true, locale: self.locale)
            return cell
        case 类别:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailDisclosureTableViewCell", forIndexPath: indexPath) as! DetailDisclosureTableViewCell
            let title = "类别"
            let placeholder="请选择"
            cell.setupCell(title, placeholder: placeholder)
            if mainCategory != nil{
                cell.updateMessage(mainCategory!+"-"+secondaryCategory!)
            }
            return cell
        case 位置:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailDisclosureTableViewCell", forIndexPath: indexPath) as! DetailDisclosureTableViewCell
            let title = "位置"
            let placeholder="请选择"
            cell.setupCell(title, placeholder: placeholder)
            if currentCity != nil {
                cell.updateMessage(currentCountry!+"-"+currentCity!)
            }
            return cell
        case 数量:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCounterTableViewCell", forIndexPath: indexPath) as! PostCounterTableViewCell
            let title = "数量"
            cell.setupCell(title, callback: updateAmount)
            return cell
        case 原价:
            let cell = tableView.dequeueReusableCellWithIdentifier("EnterTextTableViewCell", forIndexPath: indexPath) as! EnterTextTableViewCell
            let title = "原价"
            let placeholder = "买来时的原价"
            let keyboard = UIKeyboardType.DecimalPad
            let limit = 10
            cell.setupCell(title,text:originalPrice, placeholder: placeholder, keyboard: keyboard, limit: limit,callback: finishSettingOriginalPrice, rightAlign: true, locale: self.locale)
            return cell
        case 全新:
            let cell = tableView.dequeueReusableCellWithIdentifier("OptionsTableViewCell", forIndexPath: indexPath) as! OptionsTableViewCell
            let title = "全新"
            let btn1 = "全新"
            let btn2 = "用过"
            cell.setupCell(title, button1title: btn1, button2title: btn2,callback: isBrandNew)
            return cell
        case 讲价:
            let cell = tableView.dequeueReusableCellWithIdentifier("OptionsTableViewCell", forIndexPath: indexPath) as! OptionsTableViewCell
            let title = "讲价"
            let btn1 = "同意"
            let btn2 = "一口价"
            cell.setupCell(title, button1title: btn1, button2title: btn2,callback: isBargain)
            return cell
        case 置换:
            let cell = tableView.dequeueReusableCellWithIdentifier("OptionsTableViewCell", forIndexPath: indexPath) as! OptionsTableViewCell
            let title = "置换"
            let btn1 = "同意"
            let btn2 = "拒绝"
            cell.setupCell(title, button1title: btn1, button2title: btn2,callback: isExchange)
            return cell
        case 描述:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostDescriptionTableViewCell", forIndexPath: indexPath) as! PostDescriptionTableViewCell
            cell.setupCell("(选填)宝贝描述,不超过\(GLOBAL_DESCRIPTIONMAXCHAR)字",limit: GLOBAL_DESCRIPTIONMAXCHAR,callback: finishEditingDescription)
            return cell
        case let a where a==separator[0]:
            let cell = UITableViewCell()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
            label.textAlignment = .Center
            label.text = "必填"
            label.textColor = UIColor.lightGrayColor()
            label.font = UIFont.systemFontOfSize(15)
            cell.contentView.addSubview(label)
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
            return cell
        case let a where a==separator[1]:
            let cell = UITableViewCell()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
            label.textAlignment = .Center
            label.textColor = UIColor.lightGrayColor()
            label.font = UIFont.systemFontOfSize(15)
            label.text = "选填"
            cell.contentView.addSubview(label)
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
            return cell
        case let a where separator.contains(a):
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        switch indexPath.row{
        case 类别:
            let vc = PostCategoryViewController()
            vc.callback = finishChoosingCategory
            self.navigationController?.pushViewController(vc, animated: true)
        case 位置:
            let vc = PostLocationViewController()
            vc.callback = finishChoosingLocation
            self.navigationController?.pushViewController(vc, animated: true)
        default:break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if separator.contains(indexPath.row){
            return 30
        }
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == numberOfSectionsInTableView(self.tableView)-1{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let postBtn = UIButton(frame: view.frame)
            postBtn.backgroundColor = UIColor.orangeColor()
            postBtn.tintColor = UIColor.whiteColor()
            postBtn.setTitle("发布", forState: .Normal)
            postBtn.addTarget(self, action: #selector(PostItemTableViewController.postNewItem), forControlEvents: .TouchUpInside)
            view.addSubview(postBtn)
            return view
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSectionsInTableView(self.tableView)-1{
            return 44
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if [类别,位置].contains(indexPath.row){
            return true
        }
        return false
    }
    
    var productTitle:String?
    
    var mainCategory:String?
    var secondaryCategory:String?
    var categoryID:Int?
    var currentCity:String?
    var currentCountry:String?
    var location:CLPlacemark?
    var currentPrice:String?
    var amount = 1
    
    var originalPrice:String?
    var brandNew:Bool?
    var bargain:Bool?
    var exchange:Bool?
    var productDescription:String?
    
    /*
    Callback of setting title
    */
    func finishSettingTitle(title:String){
        if title == ""{
            productTitle = nil
        }else{
            productTitle = title
        }
    }
    
    /*
    Callback of setting price
    */
    func finishSettingPrice(price:String){
        if price == "" {
            currentPrice = nil
        }else{
            currentPrice = price
        }
    }
    
    /*
    Callback of choosing category view
    */
    func finishChoosingCategory(main:String,secondary:String,id:Int){
        mainCategory = main
        secondaryCategory = secondary
        categoryID = id
        self.tableView.reloadData()
    }
    
    /*
    Callback of choosing loaction view
    */
    func finishChoosingLocation(city:String,country:String,ISOCode:String,placemark:CLPlacemark){
        currentCity = city
        currentCountry = country
        let components = [NSLocaleCountryCode : ISOCode]
        let localeIdentifier = NSLocale.localeIdentifierFromComponents(components)
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        self.location = placemark
        self.locale = locale
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 价格, inSection: 0),NSIndexPath(forRow: 原价, inSection: 0),NSIndexPath(forRow: 位置, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    /*
    Callback of amount counter view
    */
    func updateAmount(amt:Int){
        self.amount = amt
    }
    
    /*
    Callback of original price
    */
    func finishSettingOriginalPrice(price:String){
        self.originalPrice = price
    }

    /*
    Callback of brandnew
    */
    func isBrandNew(flag:Int){
        switch flag{
        case 0:brandNew = nil
        case 1:brandNew = true
        case 2:brandNew = false
        default:break
        }
    }
    
    /*
    Callback of bargain
    */
    func isBargain(flag:Int){
        switch flag{
        case 0:bargain = nil
        case 1:bargain = true
        case 2:bargain = false
        default:break
        }
    }
    
    /*
    Callback of exchange
    */
    func isExchange(flag:Int){
        switch flag{
        case 0:exchange = nil
        case 1:exchange = true
        case 2:exchange = false
        default:break
        }
    }
    
    /*
    Callback of description
    */
    func finishEditingDescription(string:String){
        if string == ""{
            productDescription = nil
        }else{
            productDescription = string
        }
    }
    
    func postNewItem(){
        GLOBAL_imagesUUID = []
        if uploading != 0{
            showUploadingAlert()
            return
        }
        self.view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: {
            _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        if images.count == 0 {
            alert.message = "请至少上传一张照片!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if productTitle == nil{
            alert.message = "标题不能为空!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if currentPrice == nil{
            alert.message = "价格不能为空!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if categoryID == nil{
            alert.message = "请选择商品类别!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if location == nil{
            alert.message = "请选择所在城市!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if productDescription != nil{
            if productDescription!.characters.count > GLOBAL_DESCRIPTIONMAXCHAR {
                alert.message = "宝贝描述不能超过\(GLOBAL_DESCRIPTIONMAXCHAR)字!"
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
        }
        
        var imagepara:[[String:AnyObject]] = []
        for uuid in imagesUUID{
            imagepara.append(["uuid":uuid])
        }
        let coor = location!.location!.coordinate
        var parameter:[String:AnyObject] = ["title":productTitle!,"images":imagepara,"price":currentPrice!,"mainimage":mainIm,"category":categoryID!,"location":location!.ISOcountryCode!,"latitude":"\(coor.latitude)","longitude":"\(coor.longitude)","city":currentCity!,"country":currentCountry!,"amount":amount]
        if let originalPrice = originalPrice{
            parameter["originalPrice"] = originalPrice
        }
        if let new = brandNew {
            parameter["brandNew"] = new
        }
        if let bargain = bargain {
            parameter["bargain"] = bargain
        }
        if let exchange = exchange{
            parameter["exchange"] = exchange
        }
        if let productDescription = productDescription{
            parameter["description"] = productDescription
        }
        
        Alamofire.request(.POST, getProductURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).validate().responseJSON{
            response in
            switch response.result{
            case .Success:
                self.callback()
            case .Failure(let e):
                print(e)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
