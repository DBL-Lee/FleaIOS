//
//  UserOverviewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 05/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import MJRefresh

class UserOverviewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView:UITableView!
    
    var products:[Product] = []
    var firstCell:UserOverviewTopTableViewCell!
    var userid:Int!
    var refreshFooter:MJRefreshBackFooter!
    
    var nextURL:String = userPostedURL
    
    convenience init(userid:Int?){
        self.init()
        self.userid = userid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.registerNib(UINib(nibName: "LookAroundTableViewCell", bundle: nil), forCellReuseIdentifier: "LookAroundTableViewCell")
        self.tableView.registerNib(UINib(nibName: "UserOverviewTopTableViewCell", bundle: nil), forCellReuseIdentifier: "UserOverviewTopTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        firstCell = self.tableView.dequeueReusableCellWithIdentifier("UserOverviewTopTableViewCell") as! UserOverviewTopTableViewCell
        firstCell.selectionStyle = .None
        firstCell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        firstCell.setupCell("default", nickname: "",gender: "", location: "", auxi: "", productCount: 0, transaction: 0, goodFeedBack: 0)
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.labelText = "加载用户中"
        UserLoginHandler.instance.getUserDetailFromCloud(userid, emusername: nil){
            user in
            hud.hide(true)
            if let user = user{
                let avatar = user.avatar
                let nickname = user.nickname
                let transaction = user.transaction
                let goodfeedback = user.goodfeedback
                let posted = user.posted
                let gender = user.gender
                let location = user.location
                let introduction = user.introduction
                
                self.firstCell.setupCell(avatar, nickname: nickname, gender: gender, location: location, auxi: introduction, productCount: posted, transaction: transaction, goodFeedBack: goodfeedback)
            }else{//when load user failed
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
        }
        
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorStyle = .None
        
        refreshFooter = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        loadMore()
    }
    
//    var originalBarTintcolor:UIColor!
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        originalBarTintcolor = self.navigationController!.navigationBar.barTintColor
//        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor()
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.barTintColor = originalBarTintcolor
//    }
    
    func loadMore(){
        if nextURL != "" {
            Alamofire.request(.POST, nextURL, parameters: ["user":userid], encoding: .JSON, headers: nil).responseJSON{
                response in
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    //let previous = json["previous"].stringValue
                    let next = json["next"].stringValue
                    self.nextURL = next
                    var products:[Product] = []
                    var indexPaths:[NSIndexPath] = []
                    var current = self.products.count
                    for (_,productjson) in json["results"] {
                        products.append(Product.deserialize(productjson))
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 1))
                        current += 1
                    }
                    self.products.appendContentsOf(products)
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                    UIView.setAnimationsEnabled(true)
                    
                    if next == ""{
                        self.refreshFooter.endRefreshingWithNoMoreData()
                    }else{
                        self.refreshFooter.endRefreshing()
                    }
                case .Failure(let e):
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                    self.refreshFooter.endRefreshingWithNoMoreData()
                }
            }
        }else{
            self.refreshFooter.endRefreshingWithNoMoreData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0 {return 1}
        return products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            return firstCell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("LookAroundTableViewCell", forIndexPath: indexPath) as! LookAroundTableViewCell
            cell.tag = indexPath.row
            cell.setUpLookAroundCell(products[indexPath.row],row: indexPath.row, callback: presentPreviewVC)
            return cell
        }
    }
    
    func showProductDetail(id:Int){
        tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: id, inSection: 1))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section==1{
            let vc = ProductDetailTableViewController()
            vc.product = products[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func presentPreviewVC(productid:Int,imageid:Int){
        let vc = PreviewImagesViewController()
        vc.imagesUUID = products[productid].imageUUID
        vc.currentImage = imageid
        vc.productid = productid
        vc.showDetailButton = true
        vc.detailCallBack = showProductDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
