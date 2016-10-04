//
//  FollowerFollowingViewController.swift
//  
//
//  Created by Zichuan Huang on 09/05/2016.
//
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import MJRefresh

class FollowPeople{
    var id:Int
    var name:String
    var gender:String?
    var location:String?
    var introduction:String?
    var followed:Bool
    var avatar:String
    
    static func deserialize(json:JSON)->FollowPeople{
        let id = json["id"].intValue
        let name = json["nickname"].stringValue
        let avatar = json["avatar"].stringValue
        var gender:String?
        if let g = json["gender"].int{
            gender = g == 0 ? "女" : "男"
        }else{
            gender = ""
        }
        let location = json["location"].string
        let introduction = json["introduction"].string
        let followed = json["followed"].boolValue
        
        return FollowPeople(id:id, name: name, avatar: avatar, gender: gender, location: location, introduction: introduction, followed: followed)
    }
    init(id:Int,name:String,avatar:String,gender:String?,location:String?,introduction:String?,followed:Bool){
        self.id = id
        self.name = name
        self.gender = gender
        self.location = location
        self.introduction = introduction
        self.avatar = avatar
        self.followed = followed
    }
}

class FollowerFollowingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,TopTabBarViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var topTabBar: TopTabBarView!
    var showFollower:Bool = false
    var nextPageURL:String = ""
    var followers:[FollowPeople] = []
    var followings:[FollowPeople] = []
    
    var refreshHeader:MJRefreshNormalHeader!
    var refreshFooter:MJRefreshBackNormalFooter!
    
    
    var followerLoaded = false
    var followingLoaded = false
    
    convenience init(startWithFollowerPage:Bool){
        self.init()
        self.showFollower = startWithFollowerPage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTabBar.translatesAutoresizingMaskIntoConstraints = false
        topTabBar.addButtons(["关注","粉丝"])
        topTabBar.delegate = self
        if showFollower{
            topTabBar.startWithIndex(1)
        }
        
        self.edgesForExtendedLayout = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(UINib(nibName: "FollowerFollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowerFollowingTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.tableFooterView = UIView()
        
        
        refreshHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        refreshHeader.stateLabel.font = UIFont.systemFontOfSize(13)
        refreshHeader.lastUpdatedTimeLabel.font = UIFont.systemFontOfSize(13)
        self.tableView.mj_header = refreshHeader
        
        refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        refreshFooter.stateLabel.font = UIFont.systemFontOfSize(13)
        self.tableView.mj_footer = refreshFooter
        
        
        refreshHeader.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func didChangeToButtonNumber(number: Int) {
        if number == 0{
            if showFollower {
                showFollower = false
                if !followingLoaded {
                    refreshHeader.beginRefreshing()
                }else{
                    tableView.reloadData()
                }
            }else{
                return
            }
        }else{
            if !showFollower{
                showFollower = true
                if !followerLoaded{
                    refreshHeader.beginRefreshing()
                }else{
                    tableView.reloadData()
                }
            }else{
                return
            }
        }
    }
    
    func refresh(){
        if showFollower{
            nextPageURL = getFollowersURL
            followers = []
        }else{
            nextPageURL = getFollowingURL
            followings = []
        }
        loadMore()
    }
    
    func loadMore(){
        if nextPageURL != "" {
            Alamofire.request(.GET, nextPageURL, parameters: nil, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                self.refreshHeader.endRefreshing()
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    
                    let next = json["next"].stringValue
                    self.nextPageURL = next
                    var people:[FollowPeople] = []
                    var indexPaths:[NSIndexPath] = []
                    var current = self.showFollower ? self.followers.count : self.followings.count
                    for (_,peoplejson) in json["results"] {
                        let person = FollowPeople.deserialize(peoplejson)
                        people.append(person)
                        indexPaths.append(NSIndexPath(forRow: current, inSection: 0))
                        current += 1
                    }
                    
                    if self.showFollower {
                        self.followerLoaded = true
                        if self.followers.count == 0{
                            self.followers.appendContentsOf(people)
                            self.tableView.reloadData()
                        }else{
                            self.followers.appendContentsOf(people)
                            UIView.setAnimationsEnabled(false)
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                            UIView.setAnimationsEnabled(true)
                        }
                    }else{
                        self.followingLoaded = true
                        if self.followings.count == 0{
                            self.followings.appendContentsOf(people)
                            self.tableView.reloadData()
                        }else{
                            self.followings.appendContentsOf(people)
                            UIView.setAnimationsEnabled(false)
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                    
                    if self.nextPageURL == ""{
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showFollower{
            return followers.count
        }else{
            return followings.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowerFollowingTableViewCell", forIndexPath: indexPath) as! FollowerFollowingTableViewCell
        cell.setupCell(showFollower ? followers[indexPath.row] : followings[indexPath.row],callback: {
            self.followBtnTapped(indexPath.row)
        })
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let person = showFollower ? followers[indexPath.row] : followings[indexPath.row]
        let vc = UserOverviewController(userid: person.id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func followBtnTapped(index:Int){
        let user = showFollower ? followers[index] : followings[index]
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
                        if response.response?.statusCode < 400{
                            OverlaySingleton.addToView(self.navigationController!.view, text: "取消关注成功!")
                            self.followingLoaded = false
                            self.followerLoaded = false
                            self.refreshHeader.beginRefreshing()
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
                        if response.response?.statusCode < 400{
                            OverlaySingleton.addToView(self.navigationController!.view, text: "关注成功!")
                            self.followingLoaded = false
                            self.followerLoaded = false
                            self.refreshHeader.beginRefreshing()
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
