//
//  SearchUserTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/05/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MJRefresh
import DZNEmptyDataSet
import Alamofire
import SwiftyJSON

class SearchUserTableViewController: UITableViewController,UISearchBarDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    
    var nextURL:String = searchUserURL
    
    var searchController = UISearchController()
    var searchText = "请输入宝贝关键字或@卖家名"
    var refreshFooter:MJRefreshBackNormalFooter!
    var people:[FollowPeople] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tableView.registerNib(UINib(nibName: "FollowerFollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowerFollowingTableViewCell")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        tableView.tableFooterView = UIView()
        
        searchController = CustomSearchController(searchViewController: nil)
        searchController.searchBar.placeholder = searchText
        
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
        
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        
        searchController.searchBar.backgroundImage = UIImage()
        
        loadMore()
    }

    
    func loadMore(){
        if nextURL != ""{
            Alamofire.request(.GET, nextURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    
                    let next = json["next"].stringValue
                    self.nextURL = next
                    var people:[FollowPeople] = []
                    var indexPaths:[NSIndexPath] = []
                    var current = people.count
                    for (_,peoplejson) in json["results"] {
                        let person = FollowPeople.deserialize(peoplejson)
                        people.append(person)
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 0))
                        current += 1
                    }
                    
                    
                    if self.people.count == 0{
                        self.people.appendContentsOf(people)
                        self.tableView.reloadData()
                    }else{
                        self.people.appendContentsOf(people)
                        UIView.setAnimationsEnabled(false)
                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                        UIView.setAnimationsEnabled(true)
                    }
                   
                    
                    if self.nextURL == ""{
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        self.navigationController?.popViewControllerAnimated(true)
        
        return false
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowerFollowingTableViewCell", forIndexPath: indexPath) as! FollowerFollowingTableViewCell
        cell.setupCell(people[indexPath.row],callback: {
            self.followBtnTapped(indexPath.row)
        })
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let person = people[indexPath.row]
        let vc = UserOverviewController(userid: person.id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func followBtnTapped(index:Int){
        if !UserLoginHandler.instance.loggedIn(){
            let vc = UserLoginViewController(nibName: "UserLoginViewController", bundle: nil)
            let navi = UINavigationController(rootViewController: vc)
            self.presentViewController(navi, animated: true, completion: nil)
            
            return
        }
        
        let user = people[index]
        let alert = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        if user.followed{
            alert.message = "确认要取消关注吗?"
        }else{
            alert.message = "确认要关注吗?"
        }
        let action = UIAlertAction(title: "确定", style: .Default, handler: {
            action in
            if user.followed{
                Alamofire.request(.DELETE, unfollowUserURL, parameters: ["userid":user.id], encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                    response in
                    switch response.result{
                    case .Success:
                        user.followed = false
                        if response.response?.statusCode < 400{
                            OverlaySingleton.addToView(self.navigationController!.view, text: "取消关注成功!")
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .None)
                        }else{
                            OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                        }
                    case .Failure(let e):
                        OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                    }
                }
            }else{
                Alamofire.request(.POST, followUserURL, parameters: ["userid":user.id], encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                    response in
                    switch response.result{
                    case .Success:
                        user.followed = true
                        if response.response?.statusCode < 400{
                            OverlaySingleton.addToView(self.navigationController!.view, text: "关注成功!")
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .None)
                        }else{
                            OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                        }
                    case .Failure(let e):
                        OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                    }
                }
            }
        })
        let cancelaction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancelaction)
        self.presentViewController(alert, animated: true, completion: nil)
    }


}
