//
//  AwaitingAcceptTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import MBProgressHUD
import SwiftyJSON

class AwaitingAcceptTableViewController: UITableViewController {
    var requestURL:String = selfAwaitingURL
    var nextURL:String = ""
    var refreshFooter:MJRefreshBackFooter!
    var products:[Product] = []
    var header = ""
    var awaitingCount:[Int:Int] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.registerNib(UINib(nibName: "AwaitingAcceptTableViewCell", bundle: nil), forCellReuseIdentifier: "AwaitingAcceptTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        refreshFooter = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        
    }
    
    func reload(){
        nextURL = requestURL
        products = []
        awaitingCount = [:]
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        loadMore()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = header
        
        reload()
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
                    let next = json["next"].stringValue
                    self.nextURL = next
                    var products:[Product] = []
                    var indexPaths:[NSIndexPath] = []
                    var current = self.products.count
                    for (_,productjson) in json["results"] {
                        let product = Product.deserialize(productjson)
                        products.append(product)
                        self.awaitingCount[product.id] = productjson["awaiting"].intValue
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 0))
                        current += 1
                    }
                    
                    if self.products.count == 0{
                        self.products.appendContentsOf(products)
                        self.tableView.reloadData()
                    }else{
                        self.products.appendContentsOf(products)
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AwaitingAcceptTableViewCell", forIndexPath: indexPath) as! AwaitingAcceptTableViewCell
        cell.setupCell(products[indexPath.row], awaitingCount: awaitingCount[products[indexPath.row].id]!)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = AwaitingPeopleTableViewController()
        vc.productid = products[indexPath.row].id
        vc.totalAmount = products[indexPath.row].amount-products[indexPath.row].soldAmount
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
