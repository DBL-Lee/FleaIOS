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

class MineTableViewController: UITableViewController {

    
    
    /*
    头像
    ------------
    发布的
    卖出的
    买到的
    ------------
    好友
    ------------
    设置

    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "MineTopTableViewCell", bundle: nil), forCellReuseIdentifier: "MineTopTableViewCell")
        self.tableView.registerNib(UINib(nibName: "MineTopLoggedInTableViewCell", bundle: nil), forCellReuseIdentifier: "MineTopLoggedInTableViewCell")
        self.tableView.registerNib(UINib(nibName: "MineNormalTableViewCell", bundle: nil), forCellReuseIdentifier: "MineNormalTableViewCell")
        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }
    
    var loggedIn = false
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = "我的"
        if UserLoginHandler.instance.loggedIn(){
            Alamofire.request(.GET, userselfInfoURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                switch response.result{
                case .Success:
                    if response.response?.statusCode<400{
                        let json = JSON(response.result.value!)
                        self.posted = json["posted"].intValue
                        self.sold = json["sold"].intValue
                        self.bought = json["bought"].intValue
                        self.nickname = json["nickname"].stringValue
                        self.avatar = json["avatar"].stringValue
                        self.loggedIn = true
                        self.tableView.reloadData()
                    }else{
                        self.loggedIn = false
                        self.tableView.reloadData()
                    }
                case .Failure(let e):
                    print(e)
                    self.loggedIn = false
                    self.tableView.reloadData()
                }
                
            }
        }

    }
    var nickname = ""
    var avatar = "default"
    var posted = 0
    var sold = 0
    var bought = 0

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:return 1
        case 1:return 3
        case 2:return 1
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
                cell.loginBtn.addTarget(self, action: "presentLoginViewController", forControlEvents: .TouchUpInside)
                return cell
            }
        case (1,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我发布的", count: posted)
            }else{
                cell.setupCell("我发布的")
            }
            return cell
        case (1,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我卖出的", count: sold)
            }else{
                cell.setupCell("我卖出的")
            }
            return cell
        case (1,2):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            if loggedIn{
                cell.setupCell("我买到的", count: bought)
            }else{
                cell.setupCell("我买到的")
            }
            return cell
        case (2,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            cell.setupCell("好友")
            return cell
        case (3,0):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            cell.setupCell("设置")
            return cell
        case (3,1):
            let cell = tableView.dequeueReusableCellWithIdentifier("MineNormalTableViewCell", forIndexPath: indexPath) as! MineNormalTableViewCell
            cell.setupCell("注销")
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !loggedIn{
            if indexPath.section != 3 || indexPath.row != 0{
                presentLoginViewController()
            }
        }else{
            switch (indexPath.section,indexPath.row){
            case (3,1):
                UserLoginHandler.instance.logoutUser()
                loggedIn = false
                self.tableView.reloadData()
                
            case (1,0):
                let vc = MineProductsTableViewController()
                vc.nextURL = userPostedURL
                vc.header = "我发布的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (1,1):
                
                let vc = MineProductsTableViewController()
                vc.nextURL = userSoldURL
                vc.header = "我卖出的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case (1,2):
                
                let vc = MineProductsTableViewController()
                vc.nextURL = userBoughtURL
                vc.header = "我买到的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func presentLoginViewController(){
        let register = UserLoginViewController()
        register.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(register, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

}
