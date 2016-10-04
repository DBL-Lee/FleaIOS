//
//  SelfOrderedViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD
import Alamofire
import SwiftyJSON

class SelfOrderedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,TopTabBarViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPanel: TopTabBarView!
    
    var requestURL = selfOrderedURL
    var nextURL:String = ""
    var refreshFooter:MJRefreshBackFooter!
    var orders:[Order] = []
    var header = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.registerNib(UINib(nibName: "SelfOrderedTableViewCell", bundle: nil), forCellReuseIdentifier: "SelfOrderedTableViewCell")
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = header
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SelfOrderedTableViewCell", forIndexPath: indexPath) as! SelfOrderedTableViewCell
        cell.setupCell(orders[indexPath.row], changeAmtCallback: {
            self.showChangeAmtAlert(self.orders[indexPath.row])
            }, cancelCallback: {
            self.showCancelAlert(self.orders[indexPath.row])
        })
        cell.selectionStyle = .None
        return cell
    }
    
    func showChangeAmtAlert(order:Order){
        let alert = UIAlertController(title: "库存:\(order.product.amount-order.product.soldAmount)", message: "求购数量不得超过库存", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({
            textField in
            
            textField.keyboardType = .NumberPad
            textField.placeholder = "请输入想求购的数量"
            }
        )
        let okaction = UIAlertAction(title: "确定", style: .Default, handler: {
            action in
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            hud.label.text = "请求中"
            
            let textField = alert.textFields![0]
            let amount = textField.text == "" || textField.text == nil ? 1 : Int(textField.text!)
            let parameter = ["productid":order.product.id,"amount":amount]
            Alamofire.request(.POST, changeOrderAmtURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                hud.hideAnimated(false)
                alert.removeFromParentViewController()
                switch response.result{
                case .Success:
                    if response.response?.statusCode<400{
                        OverlaySingleton.addToView(self.navigationController!.view, text: "修改成功,请等待卖家回复!")
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
    
    func showCancelAlert(order:Order){
        let alert = UIAlertController(title: "取消求购", message: "你确定要取消求购吗?", preferredStyle: .Alert)
        let okaction = UIAlertAction(title: "确定", style: .Default, handler: {
            action in
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            hud.label.text = "请求中"
            
            let parameter = ["productid":order.product.id]
            Alamofire.request(.POST, cancelOrderURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                hud.hideAnimated(false)
                alert.removeFromParentViewController()
                switch response.result{
                case .Success:
                    if response.response?.statusCode<400{
                        OverlaySingleton.addToView(self.navigationController!.view, text: "求购已取消")
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
