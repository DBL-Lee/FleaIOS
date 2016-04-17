//
//  PendingBuyViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import UIKit
import MJRefresh
import MBProgressHUD
import Alamofire
import SwiftyJSON

class PendingBuyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPanel: UIView!
    
    let requestURL = selfPendingBuyURL
    var nextURL:String = ""
    var refreshFooter:MJRefreshBackFooter!
    var products:[Product] = []
    var header = ""
    //a map between product id and amount ordered
    var amountOrdered:[Int:Int] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.registerNib(UINib(nibName: "PendingBuyTableViewCell", bundle: nil), forCellReuseIdentifier: "PendingBuyTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorStyle = .None
        
        refreshFooter = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        
        reload()
    }
    
    func reload(){
        nextURL = requestURL
        products = []
        amountOrdered = [:]
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        loadMore()
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
                    var products:[Product] = []
                    var indexPaths:[NSIndexPath] = []
                    var current = self.products.count
                    for (_,productjson) in json["results"] {
                        let product = Product.deserialize(productjson["product"])
                        products.append(product)
                        self.amountOrdered[product.id] = productjson["amount"].intValue
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PendingBuyTableViewCell", forIndexPath: indexPath) as! PendingBuyTableViewCell
        cell.setupCell(products[indexPath.row],amount: amountOrdered[products[indexPath.row].id]!,confirmCallback: {
            _ in
            self.confirm(self.products[indexPath.row].id)
        })
        cell.selectionStyle = .None
        return cell
    }
    
    func confirm(productid:Int){
        var parameter:[String:AnyObject] = [:]
        parameter["productid"] = productid
        Alamofire.request(.POST, confirmGetProductURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
            response in
            switch response.result{
            case .Success:
                if response.response?.statusCode<400{
                    //OverlaySingleton.addToView(self.navigationController!.view, text: "成功")
                    self.reload()
                }else{
                    OverlaySingleton.addToView(self.navigationController!.view, text: JSON(response.result.value!)["error"].stringValue)
                }
            case .Failure(let e):
                print(e)
                OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
            }
        }
    }
}

