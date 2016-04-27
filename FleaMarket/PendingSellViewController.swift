//
//  PendingSellViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD
import Alamofire
import SwiftyJSON

class PendingSellViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,TopTabBarViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPanel: TopTabBarView!
    
    var requestURL:String = selfPendingSellURL
    var nextURL:String = ""
    var refreshFooter:MJRefreshBackFooter!
    var orders:[Order] = []
    var header = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.registerNib(UINib(nibName: "PendingSellTableViewCell", bundle: nil), forCellReuseIdentifier: "PendingSellTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorStyle = .None
        
        refreshFooter = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        topPanel.translatesAutoresizingMaskIntoConstraints = false
        topPanel.addButtons(["进行中","未完成","全部"])
        topPanel.delegate = self
        
        
        reload(true)
    }
    
    func reload(ongoing:Bool?){
        var query = ""
        if let ongoing = ongoing{
            if ongoing{
                query = "?ongoing=True"
            }else{
                query = "?ongoing=False"
            }
        }
        nextURL = requestURL+query
        orders = []
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        loadMore()
    }
    
    func didChangeToButtonNumber(number: Int) {
        switch number{
        case 0:
            reload(true)
        case 1:
            reload(false)
        case 2:
            reload(nil)
        default:
            break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = header
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    
    
    func loadMore(){
        if nextURL != ""{
            Alamofire.request(.GET, nextURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                MBProgressHUD.hideAllHUDsForView(self.navigationController!.view, animated: true)
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    //let previous = json["previous"].stringValue
                    
                    print(json)
                    let next = json["next"].stringValue
                    self.nextURL = next
                    var orders:[Order] = []
                    var indexPaths:[NSIndexPath] = []
                    var current = self.orders.count
                    for (_,orderjson) in json["results"] {
                        let order = Order.deserialize(orderjson)
                        orders.append(order)
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 0))
                        current += 1
                    }
                    
                    if self.orders.count == 0{
                        self.orders.appendContentsOf(orders)
                        self.tableView.reloadData()
                    }else{
                        self.orders.appendContentsOf(orders)
                        UIView.setAnimationsEnabled(false)
                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                        UIView.setAnimationsEnabled(true)
                    }
                    
                    if next == ""{
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
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PendingSellTableViewCell", forIndexPath: indexPath) as! PendingSellTableViewCell
        cell.setupCell(orders[indexPath.row],cancelCallback: {
            self.showCancelAlert(self.orders[indexPath.row])
        })
        cell.selectionStyle = .None
        return cell
    }
    
    func showCancelAlert(order:Order){
        let alert = UIAlertController(title: "取消订单", message: "你确定要取消订单吗?", preferredStyle: .Alert)
        let okaction = UIAlertAction(title: "确定", style: .Default, handler: {
            action in
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            hud.labelText = "请求中"
            
            let parameter = ["productid":order.product.id,"userid":order.buyerid]
            Alamofire.request(.POST, cancelOrderURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                hud.hide(true)
                alert.removeFromParentViewController()
                switch response.result{
                case .Success:
                    if response.response?.statusCode<400{
                        OverlaySingleton.addToView(self.navigationController!.view, text: "订单已取消")
                        self.didChangeToButtonNumber(self.topPanel.currentSelected)
                    }else{
                        let json = JSON(response.result.value!)
                        OverlaySingleton.addToView(self.navigationController!.view, text: json["error"].stringValue, duration: 3)
                    }
                case .Failure(let e):
                    print(e)
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
        })
        let cancelaction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(okaction)
        alert.addAction(cancelaction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
