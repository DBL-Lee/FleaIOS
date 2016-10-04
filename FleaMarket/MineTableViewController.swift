//
//  MineTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 18/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class MineTableViewController: UITableViewController {

    
    
    /*
    头像
    发布/关注/粉丝
    修改资料
    ------------
    待处理
    待交易的
    卖出的
    ------------
    求购的
    待交易
    买到的
    ------------
    设置

    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "MineTopTableViewCell", bundle: nil), forCellReuseIdentifier: "MineTopTableViewCell")
        self.tableView.registerNib(UINib(nibName: "MineTopLoggedInTableViewCell", bundle: nil), forCellReuseIdentifier: "MineTopLoggedInTableViewCell")
        self.tableView.registerNib(UINib(nibName: "MineNormalTableViewCell", bundle: nil), forCellReuseIdentifier: "MineNormalTableViewCell")
        self.tableView.registerNib(UINib(nibName: "PostFollowTableViewCell",bundle: nil), forCellReuseIdentifier: "PostFollowTableViewCell")
        self.tableView.tableFooterView = UIView()
        
        
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: false)
        hud.label.text = "登录中"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if UserLoginHandler.instance.loggedIn(){
            Alamofire.request(.GET, userselfInfoURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                switch response.result{
                case .Success:
                    if response.response?.statusCode<400{
                        let json = JSON(response.result.value!)
                        UserLoginHandler.instance.getUserDetailFromCloud(json["id"].intValue, emusername: nil){
                            user,bool in
                            MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                            if let user = user{
                                
                            }else{
                                
                            }
                        }
                        self.id = json["id"].intValue
                        self.posted = json["posted"].intValue
                        self.sold = json["sold"].intValue
                        self.bought = json["bought"].intValue
                        self.ordered = json["ordered"].intValue
                        self.pendingsell = json["pendingsell"].intValue
                        self.pendingbuy = json["pendingbuy"].intValue
                        self.awaiting = json["awaiting"].intValue
                        self.nickname = json["nickname"].stringValue
                        self.avatar = json["avatar"].stringValue
                        self.follower = json["followercount"].intValue
                        self.following = json["followingcount"].intValue
                        self.loggedIn = true
                        self.tableView.reloadData()
                    }else{
                        MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                        self.loggedIn = false
                        self.tableView.reloadData()
                    }
                case .Failure(let e):
                    print(e)
                    MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                    self.loggedIn = false
                    self.tableView.reloadData()
                }
                
            }
        }else{
            MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
        }
    }
    
    var loggedIn = false
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = "我的"
        

    }
    var id = 0
    var nickname = ""
    var avatar = "default"
    var posted = 0
    var sold = 0
    var bought = 0
    var ordered = 0
    var pendingsell = 0
    var pendingbuy = 0
    var awaiting = 0
    var following = 0
    var follower = 0

    func postFollowCallback(index:Int){
        switch index{
        case 0:
            let vc = MineProductsTableViewController()
            vc.requestURL = selfPostedURL
            vc.header = "我发布的"
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = FollowerFollowingViewController(startWithFollowerPage: false)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = FollowerFollowingViewController(startWithFollowerPage: true)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            if loggedIn{
                return 3
            }else{
                return 1
            }
        case 1:return 3
        case 2:return 3
        case 3:return 2
        default:return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        switch (indexPath.section,indexPath.row){
        case (0,0):
            if loggedIn{
                let cell = tableView.dequeueReusableCellWithIdentifier("MineTopLoggedInTableViewCell", forIndexPath: indexPath) as! MineTopLoggedInTableViewCell
                cell.setupCell(avatar, nickname: nickname, auxistr: "")
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("MineTopTableViewCell", forIndexPath: indexPath) as! MineTopTableViewCell
                cell.loginBtn.addTarget(self, action: #selector(MineTableViewController.presentLoginViewController), forControlEvents: .TouchUpInside)
                return cell
            }
        case (0,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("PostFollowTableViewCell", forIndexPath: indexPath) as! PostFollowTableViewCell
            cell.setupCell(posted, following: following, follower: follower, callback: postFollowCallback)
            cell.selectionStyle = .None
            return cell
        case (0,2):
            if loggedIn{
                let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
                cell.setupCell("修改资料",image: UIImage(named: "editicon.png")?.imageWithRenderingMode(.AlwaysTemplate))
                return cell
            }
            break
        case (1,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("待处理的求购",image: UIImage(named: "awaiting.png")?.imageWithRenderingMode(.AlwaysTemplate), count: awaiting)
            }else{
                cell.setupCell("待处理的求购",image: UIImage(named: "awaiting.png")?.imageWithRenderingMode(.AlwaysTemplate))
            }
            return cell
        case (1,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("待买家收货的",image: UIImage(named: "outgoing.png")?.imageWithRenderingMode(.AlwaysTemplate), count: pendingsell)
            }else{
                cell.setupCell("待买家收货的",image: UIImage(named: "outgoing.png")?.imageWithRenderingMode(.AlwaysTemplate))
            }
            return cell
        case (1,2):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我卖出的",image: UIImage(named: "sold.png")?.imageWithRenderingMode(.AlwaysTemplate), count: sold)
            }else{
                cell.setupCell("我卖出的",image: UIImage(named: "sold.png")?.imageWithRenderingMode(.AlwaysTemplate))
            }
            return cell
        case (2,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我求购的",image: UIImage(named: "order.png")?.imageWithRenderingMode(.AlwaysTemplate), count: ordered)
            }else{
                cell.setupCell("我求购的", image: UIImage(named: "order.png")?.imageWithRenderingMode(.AlwaysTemplate))
            }
            return cell
        case (2,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("待确认收货的",image: UIImage(named: "incoming.png")?.imageWithRenderingMode(.AlwaysTemplate), count: pendingbuy)
            }else{
                cell.setupCell("待确认收货的", image: UIImage(named: "incoming.png")?.imageWithRenderingMode(.AlwaysTemplate))
            }
            return cell
        case (2,2):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我买到的",image: UIImage(named: "bought.png")?.imageWithRenderingMode(.AlwaysTemplate), count: bought)
            }else{
                cell.setupCell("我买到的", image: UIImage(named: "bought.png")?.imageWithRenderingMode(.AlwaysTemplate))
            }
            return cell
        case (3,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            cell.setupCell("设置",image: UIImage(named: "settingsicon.png"))
            return cell
        case (3,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            cell.setupCell("注销")
            return cell
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !loggedIn{
            if indexPath.section != 3 || indexPath.row != 0{
                presentLoginViewController()
            }
        }else{
            switch (indexPath.section,indexPath.row){
            case (0,0):
                let vc = UserOverviewController(nibName: "UserOverviewController", bundle: nil)
                vc.userid = self.id
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (0,2): //改资料
                let vc = MineEditDetailTableViewController(style: .Plain)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (3,1): //注销
                let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: false)
                hud.label.text = "注销中"
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                    Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    UserLoginHandler.instance.logoutUser{
                        MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                        self.loggedIn = false
                        self.tableView.reloadData()
                        
                    }
                })
                
                
            case (1,0):
                let vc = AwaitingAcceptTableViewController()
                vc.header = "待处理的求购"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (1,1):
                let vc = PendingSellViewController()
                vc.header = "待买家收货"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (1,2):
                
                let vc = FInishedViewController()
                vc.requestURL = selfSoldURL
                vc.header = "我卖出的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (2,0):
                let vc = SelfOrderedViewController()
                vc.header = "我求购的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (2,1):
                let vc = PendingBuyViewController()
                vc.header = "待收货的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (2,2):
                
                let vc = FInishedViewController()
                vc.requestURL = selfBoughtURL
                vc.header = "我买到的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func presentLoginViewController(){
        let register = UserLoginViewController(nibName: "UserLoginViewController", bundle: nil)
        register.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(register, animated: true)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var sectionTitle: String!
        switch section {
        case 1:
            sectionTitle = "我在卖"
        case 2:
            sectionTitle = "我要买"
        default:
            return nil
        }
        
        let title: UILabel = UILabel()
        
        title.text = sectionTitle
        title.font = UIFont.boldSystemFontOfSize(15)
        title.frame = CGRect(x: 20, y: 0, width: 100, height: 30)
        
        let headerView:UIView = UIView()
        headerView.addSubview(title)
        headerView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        if section < 3 {
            return 30
        }
        return 10
    }
    

}
