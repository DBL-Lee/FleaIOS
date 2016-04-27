//
//  FInishedViewController.swift
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

class FInishedViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,TopTabBarViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topPanel: TopTabBarView!
    var requestURL:String!
    var nextURL:String = ""
    var refreshFooter:MJRefreshBackFooter!
    var orders:[Order] = []
    var header = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.registerNib(UINib(nibName: "FinishedTableViewCell", bundle: nil), forCellReuseIdentifier: "FinishedTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorStyle = .None
        
        refreshFooter = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        
        topPanel.addButtons(["全部","等待评价","已互评"])
        topPanel.delegate = self
        
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
            reload(nil)
        case 1:
            reload(true)
        case 2:
            reload(false)
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
        
        didChangeToButtonNumber(topPanel.currentSelected)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("FinishedTableViewCell", forIndexPath: indexPath) as! FinishedTableViewCell
        cell.setupCell(orders[indexPath.row],rateCallback: {
            _ in
            self.rate(self.orders[indexPath.row])
        })
        cell.selectionStyle = .None
        return cell
    }
    
    func rate(order:Order){
        let vc = FeedbackViewController()
        vc.order = order
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
