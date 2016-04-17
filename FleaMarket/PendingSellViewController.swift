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

class PendingSellViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPanel: UIView!
    
    var nextURL:String = selfPendingSellURL
    var refreshFooter:MJRefreshBackFooter!
    var products:[Product] = []
    var header = ""
    //a map between product id and amount ordered
    var amountOrdered:[Int:Int] = [:]
    var buyer:[Int:(String,String)] = [:]
    
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
                        self.buyer[product.id] = (productjson["buyernickname"].stringValue,productjson["buyeravatar"].stringValue)
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 0))
                        current += 1
                    }
                    self.products.appendContentsOf(products)
                    
                    
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                    UIView.setAnimationsEnabled(true)
                    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PendingSellTableViewCell", forIndexPath: indexPath) as! PendingSellTableViewCell
        cell.setupCell(products[indexPath.row],amount: amountOrdered[products[indexPath.row].id]!,buyernickname: self.buyer[products[indexPath.row].id]!.0, buyeravatar:  self.buyer[products[indexPath.row].id]!.1)
        cell.selectionStyle = .None
        return cell
    }
}
