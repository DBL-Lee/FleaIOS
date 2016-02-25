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

class FirstScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {

    var products:[Product] = []
    var productCategory:[NSManagedObject] = []
    var nextPageURL:String = "" {
        didSet{
            if nextPageURL == ""{
                self.footerView.text = "没有更多商品了"
            }else{
                self.footerView.text = "加载中..."
            }
        }
    }
    
    //static cell to hold categories
    var categoryCell:CategoryTableViewCell!
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    var footerView:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.tableView.registerNib(UINib(nibName: "FirstScreenSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "FirstScreenSearchTableViewCell")
        self.tableView.registerNib(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
        self.tableView.registerNib(UINib(nibName: "LookAroundTableViewCell", bundle: nil), forCellReuseIdentifier: "LookAroundTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = self.view.frame.height/3
        
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        
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
                            let json = JSON(value)
                            CoreDataHandler.instance.updateCategoryToCoreData(json)
                            NSUserDefaults.standardUserDefaults().setValue(currentVersion, forKey: "CategoryVersion")
                            self.productCategory = CoreDataHandler.instance.getPrimaryCategoryList()
                            self.categoryCell.setUpCollectionView(self.productCategory, callback: self.categoryChosen)
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .None)
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
        categoryCell.setUpCollectionView(productCategory, callback: categoryChosen)
        
        
        footerView = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        footerView.textAlignment = .Center
        footerView.font = UIFont.systemFontOfSize(12)
        footerView.text = "加载中..."
        tableView.tableFooterView = footerView
        
        self.refreshControl.beginRefreshing()
        refresh()
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func refresh(){
        Alamofire.request(.GET, getProductURL).responseJSON{
            response in
            switch response.result{
            case .Success:
                self.products = []
                let json = JSON(response.result.value!)
                self.nextPageURL = json["next"].stringValue
                for (_,productjson) in json["results"] {
                    self.products.append(Product.deserialize(productjson))
                }
                self.tableView.reloadData()
            case .Failure(let e):
                print(e)
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height-scrollView.frame.height
        if currentOffset/maximumOffset > 0.9 {
            loadMore()
        }
    }
    
    var loadingMore = false
    
    func loadMore(){
        if nextPageURL != "" && !loadingMore{
            loadingMore = true
            Alamofire.request(.GET, nextPageURL).responseJSON{
                response in
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    self.nextPageURL = json["next"].stringValue
                    for (_,productjson) in json["results"] {
                        self.products.append(Product.deserialize(productjson))
                    }
                    self.tableView.reloadData()
                    self.loadingMore = false
                case .Failure(let e):
                    print(e)
                }
            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("FirstScreenSearchTableViewCell", forIndexPath: indexPath) as! FirstScreenSearchTableViewCell
            cell.setSearchCallBack(searchButtonPressed)
            return cell
        case 1:
            return categoryCell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("LookAroundTableViewCell", forIndexPath: indexPath) as! LookAroundTableViewCell
            cell.selectionStyle = .None
            let avatar = UIImage(named: "avatar.png")!
            
            cell.setUpLookAroundCell(avatar, sellerName: "DBL_Lee", product: products[indexPath.row],productid: indexPath.row,callback: presentPreviewVC)
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func searchButtonPressed(){
        
        let searchVC = SearchViewController()
        searchVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0: return 1
        case 1: return 1
        case 2: return products.count
        default:return 0
        }
    }
    
    //3个section
    //1.搜索界面
    //2.分类
    //3.随便看看
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section{
        case 0: return self.view.frame.height/3
        case 1: return self.view.frame.width*2/5+50
        case 2: return -1
        default: return 0
        }
    }
    let HEADERHEIGHT:CGFloat = 10
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section==1{
            return 10
        }
        if section==2{
            return HEADERHEIGHT
        }
        return 0
    }
    
    func showProductDetail(id:Int){
        tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: id, inSection: 2))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section==2{
            let vc = ProductDetailTableViewController()
            vc.product = products[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func presentPreviewVC(productid:Int,imageid:Int){
        let vc = PreviewImagesViewController()
        vc.imagesUUID = products[productid].imageUUID
        vc.currentImage = imageid
        vc.hidesBottomBarWhenPushed = true
        vc.productid = productid
        vc.showDetailButton = true
        vc.detailCallBack = showProductDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func categoryChosen(categoryID:Int,categoryName:String){
        let vc = SearchResultViewController()
        let fetchRequest = FetchProductRequest()
        fetchRequest.primarycategory = categoryID
        vc.fetchRequest = fetchRequest
        vc.categoryText = categoryName
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
