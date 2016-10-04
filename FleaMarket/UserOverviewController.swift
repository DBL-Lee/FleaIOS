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

class UserOverviewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CustomBottomButtonBarDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var bottomBar: CustomBottomButtonBar!

    @IBOutlet weak var transparentBar: UINavigationBar!
    
    var user:User!
    var following:Bool = false
    var products:[Product] = []
    var firstCell:UserOverviewTopTableViewCell!
    var userid:Int!
    var refreshFooter:MJRefreshBackFooter!
    
    var nextURL:String = userPostedURL
    
    convenience init(userid:Int?){
        self.init()
        self.userid = userid
    }
    
    var backbtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        transparentBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        transparentBar.shadowImage = UIImage()
        transparentBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        let image = UIImage(named: "backButton.png")!.imageWithRenderingMode(.AlwaysTemplate)
        let item = UINavigationItem()
        backbtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            backbtn.setImage(image, forState: .Normal)
        backbtn.addTarget(self, action: #selector(dismiss), forControlEvents: .TouchUpInside)
        backbtn.tintColor = UIColor.whiteColor()
        
        let barBtn = UIBarButtonItem(customView: backbtn)
        
        transparentBar.tintColor = UIColor.whiteColor()
        item.leftBarButtonItem = barBtn
        transparentBar.setItems([item], animated: true)
        
        self.edgesForExtendedLayout = .Top
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.registerNib(UINib(nibName: "LookAroundTableViewCell", bundle: nil), forCellReuseIdentifier: "LookAroundTableViewCell")
        self.tableView.registerNib(UINib(nibName: "UserOverviewTopTableViewCell", bundle: nil), forCellReuseIdentifier: "UserOverviewTopTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        firstCell = self.tableView.dequeueReusableCellWithIdentifier("UserOverviewTopTableViewCell") as! UserOverviewTopTableViewCell
        firstCell.selectionStyle = .None
        firstCell.backgroundColor = UIColor.lightGrayColor()
        
        
        firstCell.setupCell(User(id: 0, emusername: "", nickname: "", avatar: "default", transaction: 0, goodfeedback: 0, posted: 0, gender: "", location: "", introduction: ""),tapCallback: avatarTapped)
        
        
        
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorStyle = .None
        
        refreshFooter = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        bottomBar.addButtons(["关注","聊天","交易评价"])
        bottomBar.delegate = self
        
        loadMore()
    }
    
    
    func dismiss(){
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func editDetail(){
        let vc = MineEditDetailTableViewController(style: .Plain)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func avatarTapped(image:String){
        let previewView = ChatImagePreviewView(image: UIImage(contentsOfFile:RetrieveImageFromS3.localDirectoryOf(image).path!)!)
        previewView.frame = self.navigationController!.view.frame
        previewView.alpha = 0
        self.navigationController?.view.addSubview(previewView)
        UIView.animateWithDuration(0.5, animations: {
            previewView.alpha = 1
        })
        
        let hud = MBProgressHUD.showHUDAddedTo(previewView, animated: true)
        hud.mode = .AnnularDeterminate
        hud.userInteractionEnabled = true
        AvatarFactory.setupImageView(S3AvatarsBucketName, imageView: previewView.imageView, image: "large-"+image, square: true, percentageHandler: {
                percentage in
            hud.progress = Float(percentage)/100.0
            }, completion: {
                hud.hideAnimated(true)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.label.text = "加载用户中"
        UserLoginHandler.instance.getUserDetailFromCloud(userid, emusername: nil){
            user,following in
            hud.hideAnimated(true)
            if let user = user{
                self.user = user
                self.following = following
                self.firstCell.setupCell(user,tapCallback: self.avatarTapped)
                if following{
                    self.bottomBar.setTitleOfButton(0, title: "已关注")
                }else{
                    self.bottomBar.setTitleOfButton(0, title: "关注")
                }
                
                if UserLoginHandler.instance.loggedIn(){
                    if UserLoginHandler.instance.userid == user.id {
                        let button = UIButton(type: .Custom)
                        let image = UIImage(named: "editproduct@2x.png")?.imageWithRenderingMode(.AlwaysTemplate)
                        button.setImage(image, forState: .Normal)
                        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                        button.addTarget(self, action: #selector(self.editDetail), forControlEvents: .TouchUpInside)
                        self.transparentBar.items![0].rightBarButtonItem = UIBarButtonItem(customView: button)
                        
                        self.bottomBar.hidden = true
                    }
                }
            }else{//when load user failed
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
        }
    }

    
    func loadMore(){
        if nextURL != "" {
            Alamofire.request(.POST, nextURL, parameters: ["user":userid], encoding: .JSON, headers: nil).responseJSON{
                response in
                MBProgressHUD.hideAllHUDsForView(self.navigationController!.view, animated: true)
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        for indexPath in tableView.indexPathsForVisibleRows!{
            if indexPath.section == 0 && indexPath.row == 0{
                UIView.animateWithDuration(0.5, animations: {
                    self.backbtn.layer.backgroundColor = UIColor.clearColor().CGColor
                })
                return
            }
        }
        
        backbtn.layer.cornerRadius = 20
        UIView.animateWithDuration(0.5, animations: {
            self.backbtn.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        })
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
            cell.setUpLookAroundCell(products[indexPath.row],row: indexPath.row, callback: presentPreviewVC, usercallback: showUserDetail)
            return cell
        }
    }
    
    func showUserDetail(id:Int){
        let vc = UserOverviewController(userid: id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProductDetail(id:Int){
        tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: id, inSection: 1))
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    
    func didPressButton(index: Int) {
        switch index{
        case 0:
            if !UserLoginHandler.instance.loggedIn(){
                let vc = UserLoginViewController(nibName: "UserLoginViewController", bundle: nil)
                let navi = UINavigationController(rootViewController: vc)
                self.presentViewController(navi, animated: true, completion: nil)
                
                return
            }
            let alert = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
            if following{
                alert.message = "确认要取消关注吗?"
            }else{
                alert.message = "确认要关注吗?"
            }
            let action = UIAlertAction(title: "确定", style: .Default, handler: {
                action in
                if self.following{
                    Alamofire.request(.DELETE, unfollowUserURL, parameters: ["userid":self.user.id], encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                        response in
                        switch response.result{
                        case .Success:
                            if response.response?.statusCode < 400{
                                OverlaySingleton.addToView(self.navigationController!.view, text: "取消关注成功!")
                                self.following = false
                                self.bottomBar.setTitleOfButton(0, title: "关注")
                            }else{
                                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                            }
                        case .Failure(let e):
                            OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                        }
                    }
                }else{
                    Alamofire.request(.POST, followUserURL, parameters: ["userid":self.user.id], encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                        response in
                        switch response.result{
                        case .Success:
                            if response.response?.statusCode < 400{
                                OverlaySingleton.addToView(self.navigationController!.view, text: "关注成功!")
                                self.following = true
                                self.bottomBar.setTitleOfButton(0, title: "已关注")
                            }else{
                                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                            }
                        case .Failure(let e):
                            OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                        }
                    }
                }
            })
            let cancelaction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancelaction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        case 1:
            if !UserLoginHandler.instance.loggedIn(){
                let vc = UserLoginViewController(nibName: "UserLoginViewController", bundle: nil)
                let navi = UINavigationController(rootViewController: vc)
                self.presentViewController(navi, animated: true, completion: nil)
                
                return
            }
            let vc = ChatViewController(userid: self.user.id, username: self.user.emusername, nickname: self.user.nickname, avatar: self.user.avatar)
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = ViewFeedbackTableViewController()
            vc.requestURL = userFeedbackURL+"?userid=\(userid)"
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
