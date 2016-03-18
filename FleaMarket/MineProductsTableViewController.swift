//
//  MineProductsTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 18/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MineProductsTableViewController: UITableViewController {
    var footerLabel:UILabel = UILabel()
    
    var nextURL:String = ""{
        didSet{
            if nextURL == ""{
                self.footerLabel.text = "没有更多商品了"
            }else{
                self.footerLabel.text = "加载中..."
            }
        }
    }
    
    var products:[Product] = []
    var header = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        loadMore()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        footerLabel.font = UIFont.systemFontOfSize(12)
        footerLabel.textAlignment = .Center
        footerLabel.textColor = UIColor.grayColor()
        if nextURL==""{
            footerLabel.text = "没有更多宝贝了"
        }else{
            footerLabel.text = "加载中..."
        }
        
        tableView.tableFooterView = footerLabel
        
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = header
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height-scrollView.frame.height
        if currentOffset/maximumOffset > 0.9 {
            loadMore()
        }
    }
    
    var loadingMore = false
    
    func loadMore(){
        if nextURL != "" && !loadingMore{
            loadingMore = true
            Alamofire.request(.GET, nextURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
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
                        products.append(Product.deserialize(productjson))
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 0))
                        current++
                    }
                    self.products.appendContentsOf(products)
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                    self.loadingMore = false
                case .Failure(let e):
                    print(e)
                }
            }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultTableViewCell", forIndexPath: indexPath) as! SearchResultTableViewCell
        cell.setupCell(products[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showDetailForProduct(indexPath.row)
    }
    
    func showDetailForProduct(index:Int){
        let vc = ProductDetailTableViewController()
        vc.product = products[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
