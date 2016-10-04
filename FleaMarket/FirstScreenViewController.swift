//
//  FirstScreenViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import MJRefresh
import CoreLocation

class FirstScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UISearchBarDelegate,DropDownButtonDelegate {
    var currentLocation = "伦敦"
    var locationBtn:DropDownButton!
    
    var products:[Product] = []
    var productCategory:[NSManagedObject] = []
    var nextPageURL:String = ""
    var searchController:UISearchController!
    var fetchRequest = FetchProductRequest()
    
    //static cell to hold categories
    var categoryCell:CategoryTableViewCell!
    
    @IBOutlet weak var tableView: UITableView!
    var refControl = UIRefreshControl()
    var refreshHeader:MJRefreshNormalHeader!
    var refreshFooter:MJRefreshBackNormalFooter!
    
    let LatitudeDefaultName = "LatitudeDefaultName"
    let LongitudeDefaultName = "LongitudeDefaultName"
    let CityDefaultName = "CityDefaultName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latitude = NSUserDefaults.standardUserDefaults().doubleForKey(LatitudeDefaultName)
        let longitude = NSUserDefaults.standardUserDefaults().doubleForKey(LongitudeDefaultName)
        if let city = NSUserDefaults.standardUserDefaults().stringForKey(CityDefaultName){
            currentLocation = city
        }
        
        if latitude != 0 {
            fetchRequest.setLocation(latitude, longitude: longitude)
        }
        
        fetchRequest.maxdistance = 100
        
        
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.tableView.registerNib(UINib(nibName: "FirstScreenSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "FirstScreenSearchTableViewCell")
        self.tableView.registerNib(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
        self.tableView.registerNib(UINib(nibName: "LookAroundTableViewCell", bundle: nil), forCellReuseIdentifier: "LookAroundTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = self.view.frame.height/3
        
     
        
        //fetch primary and secondary category from server if needed
        Alamofire.request(.GET, getCategoryVersionURL).responseString{
            response in
            switch response.result{
            case .Success(let currentVersion):
                if let version = NSUserDefaults.standardUserDefaults().objectForKey("CategoryVersion") as? String{
                    if version==currentVersion {return}
                }
                Alamofire.request(.GET, getCategoryURL,encoding: .JSON).responseJSON{
                    response in
                    switch response.result{
                    case .Success:
                        if let value = response.result.value {
                            print(value)
                            let json = JSON(value)
                            CoreDataHandler.instance.updateCategoryToCoreData(json)
                            NSUserDefaults.standardUserDefaults().setValue(currentVersion, forKey: "CategoryVersion")
                            self.productCategory = CoreDataHandler.instance.getPrimaryCategoryList()
                            self.categoryCell.setUpCollectionView(self.productCategory, callback: self.categoryChosen)
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
                        }
                    case .Failure(let error):
                        print(error)
                    }
                }
            case .Failure(let e):
                print(e)
            }
        }
        self.productCategory = CoreDataHandler.instance.getPrimaryCategoryList()
        categoryCell = self.tableView.dequeueReusableCellWithIdentifier("CategoryTableViewCell", forIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! CategoryTableViewCell
        categoryCell.selectionStyle = .None
        categoryCell.setUpCollectionView(productCategory, callback: categoryChosen)
        
        
        refreshHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        refreshHeader.stateLabel.font = UIFont.systemFontOfSize(13)
        refreshHeader.lastUpdatedTimeLabel.font = UIFont.systemFontOfSize(13)
        self.tableView.mj_header = refreshHeader
        
        refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        refreshFooter.stateLabel.font = UIFont.systemFontOfSize(13)
        self.tableView.mj_footer = refreshFooter
        
        searchController = CustomSearchController(searchViewController: nil)
        searchController.searchBar.placeholder = "请输入宝贝关键字或@卖家名"
        
        searchController.searchBar.backgroundImage = UIImage()

        
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        locationBtn = DropDownButton(frame: CGRect(x: 0, y:0,width: 68,height: 20), text: currentLocation)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: locationBtn)
        
        locationBtn.delegate = self
        
        refreshHeader.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cityChanged), name: CityChangeNotificationName, object: nil)
    }
    
    var cityChangeAlertShown = false
    
    func cityChanged(notification:NSNotification){
        let userinfo = notification.userInfo!
        let longitude = userinfo["longitude"] as! Double
        let latitude = userinfo["latitude"] as! Double
        let city = userinfo["name"] as! String
        if !cityChangeAlertShown{
            cityChangeAlertShown = true
            let alert = UIAlertController(title: "定位", message: nil, preferredStyle: .Alert)
            alert.message = "定位到您现在处在 "+city+"\n是否切换到当前位置?"
            let action = UIAlertAction(title: "好的", style: .Default, handler: {
                action in
                self.changeLocationToCountry(city, latitude: latitude, longitude: longitude)
            })
            let cancelaction = UIAlertAction(title: "不切换", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancelaction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var locationNaviVC:UINavigationController!
    func dropDownButtonTapped() {
        let vc = PostLocationViewController()
        vc.callback = finishChoosingLocation
        locationNaviVC = UINavigationController(rootViewController: vc)
        self.presentViewController(locationNaviVC, animated: true, completion: nil)
    }

    
    func finishChoosingLocation(city:String,country:String,ISOCode:String,placemark:CLPlacemark){
        self.locationNaviVC.dismissViewControllerAnimated(true, completion: nil)
        self.changeLocationToCountry(city, latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
    }
    
    func changeLocationToCountry(city:String,latitude:Double,longitude:Double){
        NSUserDefaults.standardUserDefaults().setDouble(latitude, forKey: LatitudeDefaultName)
        NSUserDefaults.standardUserDefaults().setDouble(longitude, forKey: LongitudeDefaultName)
        NSUserDefaults.standardUserDefaults().setObject(city, forKey: CityDefaultName)
        currentLocation = city
        self.locationBtn.setlabel(city)
        self.fetchRequest.setLocation(latitude, longitude: longitude)
        self.refreshHeader.beginRefreshing()
    }

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchVC, animated: true)
        return false
    }

    
    func refresh(){
        fetchRequest.request{
            previous,next,products,success in
            
            self.refreshHeader.endRefreshing()
            if success{
                self.nextPageURL = next
                self.products = products
                self.tableView.reloadData()
            }else{
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
        }
    }
    
    func loadMore(){
        if nextPageURL != "" {
            Alamofire.request(.GET, nextPageURL).responseJSON{
                response in
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    self.nextPageURL = json["next"].stringValue
                    var indexPaths:[NSIndexPath] = []
                    for (_,productjson) in json["results"] {
                        indexPaths.append(NSIndexPath(forRow: self.products.count, inSection: 1))
                        self.products.append(Product.deserialize(productjson))
                    }
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                    UIView.setAnimationsEnabled(true)
                    
                    if self.nextPageURL == ""{
                        self.refreshFooter.endRefreshingWithNoMoreData()
                    }else{
                        self.refreshFooter.endRefreshing()
                    }
                    
                case .Failure(let e):
                    self.refreshFooter.endRefreshingWithNoMoreData()
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
        }else{
            self.refreshFooter.endRefreshingWithNoMoreData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            return categoryCell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("LookAroundTableViewCell", forIndexPath: indexPath) as! LookAroundTableViewCell
            cell.tag = indexPath.row
            cell.setUpLookAroundCell(products[indexPath.row], row: indexPath.row ,callback: presentPreviewVC, usercallback: showUserDetail)
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }

    func showUserDetail(id:Int){
        let vc = UserOverviewController(userid: id)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func searchButtonPressed(){
        
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        //case 0: return 1
        case 0: return 1
        case 1: return products.count
        default:return 0
        }
    }
    
    //3个section
    //1.搜索界面
    //2.分类
    //3.随便看看
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section{
        //case 0: return self.view.frame.height/3
        case 0: return self.view.frame.width*2/5+50
        case 1: return -1
        default: return 0
        }
    }
    let HEADERHEIGHT:CGFloat = 10
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section==0{
            return HEADERHEIGHT
        }
        return 0
    }
    
    func showProductDetail(id:Int){
        tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: id, inSection: 1))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section==1{
            let vc = ProductDetailTableViewController()
            vc.product = products[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func presentPreviewVC(productid:Int,imageid:Int){
        let vc = PreviewImagesViewController(nibName: "PreviewImagesViewController", bundle: nil)
        vc.imagesUUID = products[productid].imageUUID
        vc.currentImage = imageid
        vc.hidesBottomBarWhenPushed = true
        vc.productid = productid
        vc.showDetailButton = true
        vc.detailCallBack = showProductDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //need to instantiate early to allow location service
    var categoryFetchRequest = FetchProductRequest()
    
    func categoryChosen(categoryID:Int,categoryName:String){
        let vc = SearchResultViewController()
        categoryFetchRequest.primarycategory = categoryID
        vc.fetchRequest = categoryFetchRequest
        vc.categoryText = categoryName
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
