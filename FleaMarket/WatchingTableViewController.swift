//
//  WatchingTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 03/05/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import SwiftyJSON
import MBProgressHUD
import DZNEmptyDataSet

class WatchingTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {

    
    var products:[Product] = []
    var nextPageURL:String = ""
    var searchController:UISearchController!
    var fetchRequest = FetchProductRequest()
    
    //static cell to hold categories
    var categoryCell:CategoryTableViewCell!
    
    var refreshHeader:MJRefreshNormalHeader!
    var refreshFooter:MJRefreshBackNormalFooter!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的关注"
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
        
        fetchRequest.url = followedProductURL
        
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.tableView.registerNib(UINib(nibName: "LookAroundTableViewCell", bundle: nil), forCellReuseIdentifier: "LookAroundTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = self.view.frame.height/3
        
        
        refreshHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        refreshHeader.stateLabel.font = UIFont.systemFontOfSize(13)
        refreshHeader.lastUpdatedTimeLabel.font = UIFont.systemFontOfSize(13)
        self.tableView.mj_header = refreshHeader
        
        refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        refreshFooter.stateLabel.font = UIFont.systemFontOfSize(13)
        self.tableView.mj_footer = refreshFooter
        
        if UserLoginHandler.instance.loggedIn(){
            refreshHeader.beginRefreshing()
        }
        loggedIn = UserLoginHandler.instance.loggedIn()
    }
    
    var loggedIn = false
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var string:String!
        if UserLoginHandler.instance.loggedIn(){
            string = "没有最新动态!"
        }else{
            string = "您还未登录!"
        }
        return NSAttributedString(string: string)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let string:String!
        if UserLoginHandler.instance.loggedIn(){
            string = "添加更多关注"
        }else{
            string = "登录"
        }
        
        let attributed = NSMutableAttributedString(string: string)
        attributed.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSMakeRange(0, attributed.length))
        return attributed
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        if UserLoginHandler.instance.loggedIn(){
            let searchVC = SearchViewController()
            searchVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(searchVC, animated: true)
        }else{
            let vc = UserLoginViewController(nibName: "UserLoginViewController", bundle: nil)
            vc.finishLoginCallback = refresh
            let navi = UINavigationController(rootViewController: vc)
            self.presentViewController(navi, animated: true, completion: nil)
        }
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if !UserLoginHandler.instance.loggedIn(){
            self.nextPageURL = ""
            self.products = []
            self.tableView.reloadData()
            return
        }else if !loggedIn{
            loggedIn = true
            self.refreshHeader.beginRefreshing()
        }
    }
    
    
    func refresh(){
        if !UserLoginHandler.instance.loggedIn(){
            self.nextPageURL = ""
            self.products = []
            self.tableView.reloadData()
            self.refreshHeader.endRefreshing()
            return
        }
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
            Alamofire.request(.GET, nextPageURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    self.nextPageURL = json["next"].stringValue
                    var indexPaths:[NSIndexPath] = []
                    for (_,productjson) in json["results"] {
                        indexPaths.append(NSIndexPath(forRow: self.products.count, inSection: 0))
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("LookAroundTableViewCell", forIndexPath: indexPath) as! LookAroundTableViewCell
            cell.tag = indexPath.row
            cell.setUpLookAroundCell(products[indexPath.row], row: indexPath.row ,callback: presentPreviewVC,usercallback: showUserDetail)
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return products.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func showUserDetail(id:Int){
        let vc = UserOverviewController(userid: id)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showProductDetail(id:Int){
        tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: id, inSection: 1))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = ProductDetailTableViewController()
        vc.product = products[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)

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
    


}
