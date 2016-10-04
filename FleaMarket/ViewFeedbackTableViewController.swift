//
//  ViewFeedbackTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 24/05/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh
import Alamofire
import SwiftyJSON

class Feedback{
    var content:String
    var avatar:String
    var nickname:String
    var rating:Int
    var date:NSDate
    var productTitle:String
    
    static func deserialize(json:JSON)->Feedback{
        let content = json["content"].stringValue
        let avatar = json["avatar"].stringValue
        let nickname = json["nickname"].stringValue
        let rating = json["rating"].intValue
        
        let timestring = json["time"].stringValue
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(timestring)!
        
        let title = json["product"].stringValue
        return Feedback(content: content, avatar: avatar, nickname: nickname, rating: rating, date: date, title: title)
    }
    
    init(content:String,avatar:String,nickname:String,rating:Int,date:NSDate,title:String){
        self.content = content
        self.avatar = avatar
        self.nickname = nickname
        self.rating = rating
        self.date = date
        self.productTitle = title
    }
}
class ViewFeedbackTableViewController: UITableViewController {

    var requestURL:String = ""
    private var nextURL:String = ""
    var refreshFooter:MJRefreshBackFooter!
    var feedbacks:[Feedback] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "评价"
        
        self.tableView.registerNib(UINib(nibName: "ViewFeedbackTableViewCell", bundle: nil), forCellReuseIdentifier: "ViewFeedbackTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        refreshFooter = MJRefreshBackFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        reload()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Table view data source

    func reload() {
        nextURL = requestURL
        feedbacks = []
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
                    print(json)
                    //let previous = json["previous"].stringValue
                    let next = json["next"].stringValue
                    self.nextURL = next
                    var feedbacks:[Feedback] = []
                    var indexPaths:[NSIndexPath] = []
                    var current = self.feedbacks.count
                    for (_,feedbackjson) in json["results"] {
                        feedbacks.append(Feedback.deserialize(feedbackjson))
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 0))
                        current += 1
                    }
                    
                    if self.feedbacks.count == 0{
                        self.feedbacks.appendContentsOf(feedbacks)
                        self.tableView.reloadData()
                    }else{
                        self.feedbacks.appendContentsOf(feedbacks)
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
        return feedbacks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ViewFeedbackTableViewCell", forIndexPath: indexPath) as! ViewFeedbackTableViewCell
        cell.setupCell(feedbacks[indexPath.row])
        return cell
    }

   
}
