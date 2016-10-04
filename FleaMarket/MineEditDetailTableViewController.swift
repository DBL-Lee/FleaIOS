//
//  MineEditDetailTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 03/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import AWSS3
import TOCropViewController
import MBProgressHUD
import CoreLocation

class MineEditDetailTableViewController: UITableViewController, TOCropViewControllerDelegate {
    /*
     0,0 头像
     0,1 昵称 (无法修改)
     0,2 性别
     0,3 地区
     0,4 简介
     */
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改资料"
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 40
        self.tableView.tableFooterView = UIView()
        self.tableView.alwaysBounceVertical = false
        self.tableView.registerNib(UINib(nibName: "DetailDisclosureTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailDisclosureTableViewCell")
        self.tableView.registerNib(UINib(nibName: "AvatarEditTableViewCell", bundle: nil), forCellReuseIdentifier: "AvatarEditTableViewCell")
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.mode = .Indeterminate
        hud.label.text = "正在加载用户信息"
        CoreDataHandler.instance.getUserFromCoreData(UserLoginHandler.instance.userid, emusername: nil){
            user in
            self.user = user
            self.tableView.reloadData()
            MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section,indexPath.row){
        case (0,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("AvatarEditTableViewCell", forIndexPath: indexPath) as! AvatarEditTableViewCell
            cell.setupCell("头像", avatar: UserLoginHandler.instance.avatarImageURL)
            return cell
        case (0,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailDisclosureTableViewCell", forIndexPath: indexPath) as! DetailDisclosureTableViewCell
            cell.setupCell("昵称", placeholder: "")
            cell.selectionStyle = .None
            cell.updateMessage(UserLoginHandler.instance.nickname)
            cell.detailLabel.textColor = UIColor.lightGrayColor()
            cell.rightConstraint.constant = 46
            cell.accessoryType = .None
            return cell
        case (0,2):
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailDisclosureTableViewCell", forIndexPath: indexPath) as! DetailDisclosureTableViewCell
            cell.setupCell("性别", placeholder: "")
            if let user = user{
                if let gender = user.gender{
                    cell.updateMessage(gender)
                    cell.detailLabel.textColor = UIColor.lightGrayColor()
                }
            }
            return cell
        case (0,3):
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailDisclosureTableViewCell", forIndexPath: indexPath) as! DetailDisclosureTableViewCell
            cell.setupCell("位置", placeholder: "")
            if let user = user{
                if let location = user.location{
                    cell.updateMessage(location)
                    cell.detailLabel.textColor = UIColor.lightGrayColor()
                }
            }
            return cell
        case (0,4):
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailDisclosureTableViewCell", forIndexPath: indexPath) as! DetailDisclosureTableViewCell
            cell.setupCell("简介", placeholder: "")
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
    func showCamera(){
        let vc = PhotoCameraViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.callback = changeAvatar
        vc.MAXPHOTO = 1
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    func showAlbum(){
        let vc = PhotoAlbumViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.callback = cropImage
        vc.MAXPHOTO = 1
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    func cropImage(images:[UIImage]){
        let vc = TOCropViewController(image: images.first!)
        vc.aspectRatioPreset = .PresetSquare
        vc.aspectRatioLockEnabled = true
        vc.delegate = self
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        self.dismissViewControllerAnimated(true){
            _ in
            self.changeAvatar([image])
            
        }
    }
    
    func changeAvatar(images:[UIImage]){
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.mode = .Determinate
        hud.label.text = "上传头像中"
        
        //first upload avatar
        let uuid = NSUUID().UUIDString+".png"
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        let fileName = "large-"+uuid+".png"
        let fileURL = LocalUploadDirectory.URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        let imageData = UIImagePNGRepresentation(images.first!)
        imageData!.writeToFile(filePath, atomically: true)
        
        uploadRequest.bucket = S3AvatarsBucketName
        uploadRequest.key = fileName
        uploadRequest.body = fileURL
        
        uploadRequest.uploadProgress = {
            (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if totalBytesExpectedToSend > 0 {
                    let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                    hud.progress = progress / 2.0
                }
            })
        }
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock {
            task -> AnyObject! in
            if let error = task.error {
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
            
            if let exception = task.exception {
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
            
            //upload complete
            if task.result != nil{
                
                
                //then upload thumbnail
                do{ //copy to download directory
                    try NSFileManager.defaultManager().copyItemAtPath(filePath, toPath: LocalDownloadDirectory.URLByAppendingPathComponent(fileName).path!)
                }catch let error{
                    print(error)
                }
                let uploadRequest = AWSS3TransferManagerUploadRequest()
                let fileName = uuid+".png"
                let fileURL = LocalUploadDirectory.URLByAppendingPathComponent(fileName)
                let filePath = fileURL.path!
                let imageData = UIImagePNGRepresentation(images.first!.thumbnailOfSize(THUMBNAILSIZE))
                imageData!.writeToFile(filePath, atomically: true)
                
                uploadRequest.bucket = S3AvatarsBucketName
                uploadRequest.key = fileName
                uploadRequest.body = fileURL
                
                uploadRequest.uploadProgress = {
                    (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if totalBytesExpectedToSend > 0 {
                            let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                            hud.progress = progress / 2.0 + 0.5
                        }
                    })
                }
                
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                transferManager.upload(uploadRequest).continueWithBlock {
                    task -> AnyObject! in
                    if let error = task.error {
                        OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                    }
                    
                    if let exception = task.exception {
                        OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                    }
                    
                    //upload thumbnail complete
                    if task.result != nil{
                        
                        hud.mode = .Indeterminate
                        hud.label.text = "与服务器同步中"
                        
                        do{ //copy to download directory
                            try NSFileManager.defaultManager().copyItemAtPath(filePath, toPath: LocalDownloadDirectory.URLByAppendingPathComponent(fileName).path!)
                        }catch let error{
                            print(error)
                        }
                        UserLoginHandler.instance.editDetailOfCurrentUser(uuid+".png"){ //change info on server
                            success in
                            
                            hud.hideAnimated(true)
                            
                            if success{
                                if let user = self.user{
                                    self.user = CoreDataHandler.instance.updateUserToCoreData(user.id, emusername: user.emusername, nickname: user.nickname, avatar: fileName, transaction: user.transaction, goodfeedback: user.goodfeedback, posted: user.posted, gender: user.gender == nil ? "" : user.gender!, location: user.location == nil ? "" : user.location!, introduction: user.introduction == nil ? "" : user.introduction!)
                                    self.tableView.reloadData()
                                }
                            }else{
                                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                            }
                        }
                    }
                    return nil
                }
            }
            return nil
        }
    }
    
    func changeGender(gender:String){
        if let user = self.user{
            self.user = CoreDataHandler.instance.updateUserToCoreData(user.id, emusername: user.emusername, nickname: user.nickname, avatar: user.avatar, transaction: user.transaction, goodfeedback: user.goodfeedback, posted: user.posted, gender: gender, location: user.location == nil ? "" : user.location!, introduction: user.introduction == nil ? "" : user.introduction!)
            self.tableView.reloadData()
        }
    }
    
    func changeLocation(currentCity:String,currentCountry:String,currentCountryCode:String,currentPlacemark:CLPlacemark){
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.label.text = "与服务器同步中"
        UserLoginHandler.instance.editDetailOfCurrentUser(location: currentCity+","+currentCountry){
            success in
            hud.hideAnimated(true)
            if success{
                if let user = self.user{
                    self.user = CoreDataHandler.instance.updateUserToCoreData(user.id, emusername: user.emusername, nickname: user.nickname, avatar: user.avatar, transaction: user.transaction, goodfeedback: user.goodfeedback, posted: user.posted, gender: user.gender == nil ? "" : user.gender!, location: currentCity+","+currentCountry, introduction: user.introduction == nil ? "" : user.introduction!)
                    self.tableView.reloadData()
                }
            }else{
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (indexPath.section,indexPath.row){
        case (0,0):
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
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        case (0,2):
            let vc = GenderEditTableViewController(style: .Plain)
            vc.callback = changeGender
            self.navigationController?.pushViewController(vc, animated: true)
        case (0,3):
            let vc = PostLocationViewController()
            vc.callback = changeLocation
            self.navigationController?.pushViewController(vc, animated: true)
        case (0,4):
            let vc = IntroductionEditViewController()
        
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

}
