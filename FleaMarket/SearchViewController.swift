//
//  SearchViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 16/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController,UISearchBarDelegate,UISearchResultsUpdating,UISearchControllerDelegate {
    
    var searchController:CustomSearchController!
    var clearButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        history = CoreDataHandler.instance.getSearchHistory()
        
        tableView.keyboardDismissMode = .OnDrag
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchController = CustomSearchController(searchViewController: nil)
        searchController.searchBar.placeholder = "请输入宝贝关键字或@卖家名"
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        self.navigationItem.hidesBackButton = true
        
//        let rightBtn = UIButton(type: .Custom)
//        rightBtn.setTitle("取消", forState: .Normal)
//        rightBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
//        rightBtn.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
//        rightBtn.titleLabel!.font = UIFont.systemFontOfSize(15)
//        rightBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
//        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        let rightBtn = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Done, target: self, action: "dismiss")
        rightBtn.setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(15)], forState: .Normal)

        self.navigationItem.rightBarButtonItem = rightBtn
        
        clearButton = UIButton(type: .Custom)
        clearButton.setTitle("清楚搜索历史记录", forState: .Normal)
        clearButton.addTarget(self, action: "clearHistory", forControlEvents: .TouchUpInside)
    }
    
    func clearHistory(){
        CoreDataHandler.instance.clearSearchHistory()
        history = []
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80))
        clearButton.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        clearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        clearButton.titleLabel!.font = UIFont.systemFontOfSize(12)
        clearButton.layer.borderColor = UIColor.blackColor().CGColor
        clearButton.layer.borderWidth = 1
        view.addSubview(clearButton)
        clearButton.center = view.center
        self.tableView.tableFooterView = view
        clearButton.autoresizingMask = [.FlexibleTopMargin,.FlexibleBottomMargin]
        
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.barTintColor = UIColor(white: 0.95, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.edgesForExtendedLayout = .None
        self.navigationItem.titleView?.tintColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        
        self.definesPresentationContext = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchController.active = true
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        dispatch_async(dispatch_get_main_queue(), {
            self.searchController.searchBar.becomeFirstResponder()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        self.definesPresentationContext = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            continueSearching(searchText)
        }
    }
    
    func continueSearching(searchText:String){
        CoreDataHandler.instance.addSearchHistoryToCoreData(searchText)
        let vc = SearchResultViewController()
        vc.nextURL = getProductURL+"?title="+searchText
        vc.searchText = searchText
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func dismiss(){
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    deinit{
        if let superView = searchController.view.superview
        {
            superView.removeFromSuperview()
        }
    }
    
    var history:[String] = []
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = history[indexPath.row]
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        continueSearching(history[indexPath.row])
    }
    

    //not implemented fuzzy search
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}
