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
    修改资料
    ------------
    发布的
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
        self.tableView.tableFooterView = UIView()
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.labelText = "登录中"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }
    
    var loggedIn = false
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = "我的"
        if UserLoginHandler.instance.loggedIn(){
            Alamofire.request(.GET, userselfInfoURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                switch response.result{
                case .Success:
                    if response.response?.statusCode<400{
                        let json = JSON(response.result.value!)
                        UserLoginHandler.instance.getUserDetailFromCloud(json["id"].intValue, emusername: nil){
                            user in
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            if loggedIn{
                return 2
            }else{
                return 1
            }
        case 1:return 4
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
                cell.setupCell(avatar, nickname: nickname)
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("MineTopTableViewCell", forIndexPath: indexPath) as! MineTopTableViewCell
                cell.loginBtn.addTarget(self, action: #selector(MineTableViewController.presentLoginViewController), forControlEvents: .TouchUpInside)
                return cell
            }
        case (0,1):
            if loggedIn{
                let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
                cell.setupCell("修改资料",image: UIImage(named: "editicon.png"))
                return cell
            }
            break
        case (1,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我发布的",image: UIImage(named: "postedicon.png") , count: posted)
            }else{
                cell.setupCell("我发布的",image: UIImage(named: "postedicon.png"))
            }
            return cell
        case (1,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("待处理的求购",image: UIImage(named: "soldicon.png"), count: awaiting)
            }else{
                cell.setupCell("待处理的求购",image: UIImage(named: "soldicon.png"))
            }
            return cell
        case (1,2):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("待买家收货的",image: UIImage(named: "soldicon.png"), count: pendingsell)
            }else{
                cell.setupCell("待买家收货的",image: UIImage(named: "soldicon.png"))
            }
            return cell
        case (1,3):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我卖出的",image: UIImage(named: "soldicon.png"), count: sold)
            }else{
                cell.setupCell("我卖出的",image: UIImage(named: "soldicon.png"))
            }
            return cell
        case (2,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我求购的",image: UIImage(named: "boughticon.png"), count: ordered)
            }else{
                cell.setupCell("我求购的", image: UIImage(named: "boughticon.png"))
            }
            return cell
        case (2,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("待确认收货的",image: UIImage(named: "boughticon.png"), count: pendingbuy)
            }else{
                cell.setupCell("待确认收货的", image: UIImage(named: "boughticon.png"))
            }
            return cell
        case (2,2):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我买到的",image: UIImage(named: "boughticon.png"), count: bought)
            }else{
                cell.setupCell("我买到的", image: UIImage(named: "boughticon.png"))
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
//                let vc = UserOverviewController(userid: self.id, nextURL: userPostedURL)
//                NSBundle.mainBundle().loadNibNamed("UserOverviewController", owner: vc, options: nil)
                let vc = UserOverviewController(nibName: "UserOverviewController", bundle: nil)
                vc.userid = self.id
                vc.nextURL = userPostedURL
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (0,1): //改资料
                let vc = MineEditDetailTableViewController(style: .Plain)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (3,1): //注销
                let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
                hud.labelText = "注销中"
                UserLoginHandler.instance.logoutUser{
                    MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                    self.loggedIn = false
                    self.tableView.reloadData()
                    
                }
                
            case (1,0):
                let vc = MineProductsTableViewController()
                vc.nextURL = selfPostedURL
                vc.header = "我发布的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (1,1):
                let vc = AwaitingAcceptTableViewController()
                vc.header = "待处理的求购"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (1,2):
                let vc = PendingSellViewController()
                vc.header = "待买家收货"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (1,3):
                
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
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

}
