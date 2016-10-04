//
//  AwaitingPeopleTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 16/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class AwaitingPeopleTableViewController: UITableViewController {
    var productid:Int!
    var totalAmount:Int!
    
    var orders:[Order] = []
    var avatar:[String] = []
    var nickname:[String] = []
    var amount:[Int] = []
    var userid:[Int] = []
    var time:[NSDate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "库存:\(totalAmount)"
        
        
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.registerNib(UINib(nibName: "AwaitingPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "AwaitingPeopleTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        loadData()
        
    }
    
    func loadData(){
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        
        orders = []
        avatar = []
        nickname = []
        amount = []
        userid = []
        time = []
        
        Alamofire.request(.GET, selfAwaitingPeopleURL+"?productid=\(productid)", parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).validate().responseJSON{
            response in
            MBProgressHUD.hideAllHUDsForView(self.navigationController!.view, animated: true)
            switch response.result{
            case .Success:
                let json = JSON(response.result.value!)
                for (_,order) in json{
                    self.avatar.append(order["avatar"].stringValue)
                    self.nickname.append(order["nickname"].stringValue)
                    self.amount.append(order["amount"].intValue)
                    self.userid.append(order["userid"].intValue)
                    
                    let timestring = order["time_ordered"].stringValue
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                    dateFormatter.timeZone = NSTimeZone(name: "UTC")
                    let time_ordered = dateFormatter.dateFromString(timestring)!
                    
                    self.time.append(time_ordered)
                    
                }
                self.tableView.reloadData()
            case .Failure(let e):
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return avatar.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AwaitingPeopleTableViewCell", forIndexPath: indexPath) as! AwaitingPeopleTableViewCell
        cell.setupCell(avatar[indexPath.row], nickname: nickname[indexPath.row], amount: amount[indexPath.row],time: self.time[indexPath.row],callback: {
            _ in
            self.chooseUser(self.userid[indexPath.row],amount: self.amount[indexPath.row])
        })
        
        return cell
    }
    
    func chooseUser(userid:Int,amount:Int){
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        var parameter:[String:AnyObject] = [:]
        parameter["productid"] = productid
        parameter["userid"] = userid
        Alamofire.request(.POST, acceptBuyRequestURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
            response in
            hud.hideAnimated(true)
            switch response.result{
            case .Success:
                if response.response?.statusCode<400{
                    self.totalAmount = self.totalAmount - amount
                    self.title = "库存:\(self.totalAmount)"
                    self.loadData()
                    
                }else{
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            case .Failure(let e):
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
        }
    }
}
