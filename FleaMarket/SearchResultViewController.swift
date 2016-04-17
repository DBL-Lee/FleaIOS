//
//  SearchResultViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class SearchResultViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate,UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPanel: UIView!

    @IBOutlet weak var categoryBtn: UIButton!
    var categoryText = "分类 "
    var categoryAttr:NSMutableAttributedString!
    var categoryAttrChosen:NSMutableAttributedString!
    
    var categoryView:CategoryDropDownTableView!
    
    @IBOutlet weak var sortBtn: UIButton!
    var sortText = "排序 "
    var sortAttr:NSMutableAttributedString!
    var sortAttrChosen:NSMutableAttributedString!
    
    var sortView:OrderingTableView!
    
    @IBOutlet weak var filterBtn: UIButton!
    var filterText = "筛选 "
    var filterAttr:NSMutableAttributedString!
    var filterAttrChosen:NSMutableAttributedString!
    
    var filterView:FilterDropDownTableView!
    
    var upAttach:NSAttributedString!
    var downAttach:NSAttributedString!
    
    var searchController = UISearchController()
    
    @IBOutlet weak var dropDownOverlay:UIView!
    
    var fetchRequest:FetchProductRequest!
    var nextURL:String = ""
    
    var searchText = "请输入宝贝关键字或@卖家名"
    var refreshFooter:MJRefreshBackNormalFooter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        
        
        tableView.registerNib(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultTableViewCell")
        
        topPanel.addBorder(edges: [.Bottom], colour: UIColor.lightGrayColor(), thickness: 0.5)
        
        let downattachment = NSTextAttachment()
        let im = UIImage(named: "dropdown.png")!
        var height:CGFloat = 30*0.5
        let scale = height/im.size.height
        downattachment.image = UIImage(CGImage: im.CGImage!, scale: 1/scale, orientation: .Up)
        downAttach = NSAttributedString(attachment: downattachment)
        
        let upattachment = NSTextAttachment()
        let im2 = UIImage(named: "dropup.png")!
        upattachment.image = UIImage(CGImage: im2.CGImage!, scale: 1/scale, orientation: .Up)
        upAttach = NSAttributedString(attachment: upattachment)
        
        categoryAttr = NSMutableAttributedString(string: categoryText)
        categoryAttrChosen = NSMutableAttributedString(string: categoryText)
        categoryAttr.appendAttributedString(downAttach)
        categoryAttrChosen.appendAttributedString(upAttach)
        
        sortAttr = NSMutableAttributedString(string: sortText)
        sortAttrChosen = NSMutableAttributedString(string: sortText)
        sortAttr.appendAttributedString(downAttach)
        sortAttrChosen.appendAttributedString(upAttach)
        
        
        filterAttr = NSMutableAttributedString(string: filterText)
        filterAttrChosen = NSMutableAttributedString(string: filterText)
        filterAttr.appendAttributedString(downAttach)
        filterAttrChosen.appendAttributedString(upAttach)
        
        categoryBtn.setAttributedTitle(categoryAttr, forState: .Normal)
        categoryBtn.setAttributedTitle(categoryAttrChosen, forState: .Selected)
        
        sortBtn.setAttributedTitle(sortAttr, forState: .Normal)
        sortBtn.setAttributedTitle(sortAttrChosen, forState: .Selected)
        
        filterBtn.setAttributedTitle(filterAttr, forState: .Normal)
        filterBtn.setAttributedTitle(filterAttrChosen, forState: .Selected)
        
        searchController = CustomSearchController(searchViewController: nil)
        searchController.searchBar.placeholder = searchText
        
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        categoryBtn.addTarget(self, action: #selector(SearchResultViewController.tapCategory), forControlEvents: .TouchUpInside)
        
        filterBtn.addTarget(self, action: #selector(SearchResultViewController.tapFilter), forControlEvents: .TouchUpInside)
        
        sortBtn.addTarget(self, action: #selector(SearchResultViewController.tapSort), forControlEvents: .TouchUpInside)
        
        self.dropDownOverlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dropDownOverlay.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchResultViewController.tapOnOverlay(_:)))
        tap.delegate = self
        self.dropDownOverlay.addGestureRecognizer(tap)
        
        height = dropDownOverlay.frame.height*0.8
        
        self.categoryView = CategoryDropDownTableView(frame: CGRect(x: 0, y: 0, width: dropDownOverlay.frame.width, height: height), callback: categoryChosen)
        categoryView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.dropDownOverlay.addSubview(categoryView)
        
        self.filterView = FilterDropDownTableView(frame: CGRect(x: 0, y: 0, width: dropDownOverlay.frame.width, height: self.dropDownOverlay.frame.height))
        filterView.callback = filterCallBack
        self.filterView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.dropDownOverlay.addSubview(filterView)
        
        self.sortView = OrderingTableView(frame: CGRect(x: 0, y: 0, width: dropDownOverlay.frame.width, height: self.dropDownOverlay.frame.height), style: .Plain)
        self.sortView.callback = finishChoosingOrder
        self.sortView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.dropDownOverlay.addSubview(sortView)
        
        fetchRequest.request(parseRequest)
        
        refreshFooter = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = refreshFooter
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(categoryView) || touch.view!.isDescendantOfView(filterView){
            return false
        }
        return true
    }
    
    func tapOnOverlay(tap:UITapGestureRecognizer){
        if categorySubviewShowing{
            categorySubviewShowing = false
            removeCategorySubview()
            categoryBtn.selected = false
        }
        if filterSubviewShowing{
            filterSubviewShowing = false
            removeFilterSubview()
            filterBtn.selected = false
        }
    }
    
    
    func clearOtherView(){
        if categorySubviewShowing{
            categoryBtn.selected = false
            categorySubviewShowing = false
            removeCategorySubview(false)
        }
        if filterSubviewShowing{
            filterBtn.selected = false
            filterSubviewShowing = false
            removeFilterSubview(false)
        }
        if sortSubviewShowing{
            sortBtn.selected = false
            sortSubviewShowing = false
            removeSortSubview(false)
        }
    }
    var categorySubviewShowing = false
    
    func tapCategory(){
        categoryBtn.selected = !categoryBtn.selected
        if categorySubviewShowing{
            categorySubviewShowing = false
            removeCategorySubview()
        }else{
            dropDownOverlay.bringSubviewToFront(categoryView)
            clearOtherView()
            categorySubviewShowing = true
            presentCategorySubview()
        }
    }
    
    var filterSubviewShowing = false
    
    func tapFilter(){
        filterBtn.selected = !filterBtn.selected
        if filterSubviewShowing{
            filterSubviewShowing = false
            removeFilterSubview()
        }else{
            dropDownOverlay.bringSubviewToFront(filterView)
            clearOtherView()
            filterSubviewShowing = true
            presentFilterSubview()
        }
    }
    
    var sortSubviewShowing = false
    
    func tapSort(){
        sortBtn.selected = !sortBtn.selected
        if sortSubviewShowing{
            sortSubviewShowing = false
            removeSortSubview()
        }else{
            dropDownOverlay.bringSubviewToFront(sortView)
            clearOtherView()
            sortSubviewShowing = true
            presentSortSubview()
        }
    }
    
    func filterCallBack(brandnew:Bool,bargain:Bool,exchange:Bool,distance:Int?,minPrice:Int?,maxPrice:Int?){
        if brandnew {
            fetchRequest.brandNew = true
        }else{
            fetchRequest.brandNew = nil
        }
        if bargain {
            fetchRequest.bargain = true
        }else{
            fetchRequest.bargain = nil
        }
        if exchange {
            fetchRequest.exchange = true
        }else{
            fetchRequest.exchange = nil
        }
        fetchRequest.minprice = minPrice
        fetchRequest.maxprice = maxPrice

        fetchRequest.maxdistance = distance
        
        fetchRequest.request(parseRequest)
        tapFilter()
    }
    
    func finishChoosingOrder(type:FetchRequestSortType,text:String){
        fetchRequest.sortType = type
        fetchRequest.request(parseRequest)
        let d = NSMutableAttributedString(string: text+" ")
        d.appendAttributedString(downAttach)
        sortAttr = d
        let u = NSMutableAttributedString(string: text+" ")
        u.appendAttributedString(upAttach)
        sortAttrChosen = d
        sortBtn.setAttributedTitle(sortAttr, forState: .Normal)
        sortBtn.setAttributedTitle(sortAttrChosen, forState: .Selected)
        tapSort()
    }

    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let vc = SearchViewController()
        vc.fetchRequest = self.fetchRequest
        self.navigationController?.pushViewController(vc, animated: false)
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.barTintColor = UIColor(white: 0.95, alpha: 1)
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
        self.navigationItem.hidesBackButton = true
        let image = UIImage(named: "backButton.png")
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(SearchResultViewController.dismiss), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationController?.navigationBar.barTintColor = UIColor(white: 0.95, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        self.dropDownOverlay.hidden = true
        
        
    }
    
    func dismiss(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.categoryView.transform = CGAffineTransformMakeTranslation(0, -self.categoryView.frame.height)
        self.filterView.transform = CGAffineTransformMakeTranslation(0, -self.filterView.frame.height)
        self.sortView.transform = CGAffineTransformMakeTranslation(0, -self.sortView.frame.height)
    }
    
    func parseRequest(_:String,next:String,p:[Product],success:Bool){
        if success{
            self.nextURL = next
            self.products = p
            self.tableView.reloadData()
        }else{
            OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
        }
    }
    
    func loadMore(){
        if nextURL != ""{
            Alamofire.request(.GET, nextURL).responseJSON{
                response in
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    self.nextURL = json["next"].stringValue
                    var indexPaths:[NSIndexPath] = []
                    for (_,productjson) in json["results"] {
                        indexPaths.append(NSIndexPath(forRow: self.products.count, inSection: 0))
                        self.products.append(Product.deserialize(productjson))
                    }
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                    UIView.setAnimationsEnabled(true)
                    
                    if self.nextURL == ""{
                        self.refreshFooter.endRefreshingWithNoMoreData()
                    }else{
                        self.refreshFooter.endRefreshing()
                    }
                case .Failure(let e):
                    print(e)
                    self.refreshFooter.endRefreshingWithNoMoreData()
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
        }else{
            
            self.refreshFooter.endRefreshingWithNoMoreData()
        }
    }
    
    func categoryChosen(primary:Bool,id:Int,name:String){
        categoryBtn.selected = false
        if primary{
            if id == -1{
                fetchRequest.primarycategory = nil
            }else{
                fetchRequest.primarycategory = id
            }
            fetchRequest.secondarycategory = nil
        }else{
            fetchRequest.primarycategory = nil
            fetchRequest.secondarycategory = id
        }
        fetchRequest.request(parseRequest)
        let d = NSMutableAttributedString(string: name+" ")
        d.appendAttributedString(downAttach)
        categoryAttr = d
        let u = NSMutableAttributedString(string: name+" ")
        u.appendAttributedString(upAttach)
        categoryAttrChosen = d
        categoryBtn.setAttributedTitle(categoryAttr, forState: .Normal)
        categoryBtn.setAttributedTitle(categoryAttrChosen, forState: .Selected)
        removeCategorySubview()
    }
    
    func presentDropDownOverlay(){
        dropDownOverlay.hidden = false
    }
    
    func removeDropDownOverlay(){
        dropDownOverlay.hidden = true
    }
    
    func presentCategorySubview(){
        presentDropDownOverlay()
        self.categoryView.transform = CGAffineTransformMakeTranslation(0, -self.categoryView.frame.height)
        UIView.animateWithDuration(0.5, animations: {
            self.categoryView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func removeCategorySubview(removeOverlay:Bool = true){
        UIView.animateWithDuration(0.5, animations: {
            self.categoryView.transform = CGAffineTransformMakeTranslation(0, -self.categoryView.frame.height)
            }){
                _ in
                if removeOverlay{
                    self.removeDropDownOverlay()
                }
        }
    }
    
    func presentSortSubview(){
        presentDropDownOverlay()
        self.sortView.needsShowing()
        self.sortView.transform = CGAffineTransformMakeTranslation(0, 0)
        self.sortView.frame.origin = CGPoint.zero
        self.sortView.transform = CGAffineTransformMakeTranslation(0, -self.sortView.frame.height)
        UIView.animateWithDuration(0.5, animations: {
            self.sortView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func removeSortSubview(removeOverlay:Bool = true){
        UIView.animateWithDuration(0.5, animations: {
            self.sortView.transform = CGAffineTransformMakeTranslation(0, -self.sortView.frame.height)
            }){
                _ in
                if removeOverlay{
                    self.removeDropDownOverlay()
                }
        }
    }
    
    func presentFilterSubview(){
        presentDropDownOverlay()
        self.filterView.needsShowing()
        self.filterView.transform = CGAffineTransformMakeTranslation(0, 0)
        self.filterView.frame.origin = CGPoint.zero
        self.filterView.transform = CGAffineTransformMakeTranslation(0, -self.filterView.frame.height)
        UIView.animateWithDuration(0.5, animations: {
            self.filterView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func removeFilterSubview(removeOverlay:Bool = true){
        UIView.animateWithDuration(0.5, animations: {
            self.filterView.transform = CGAffineTransformMakeTranslation(0, -self.filterView.frame.height)
            }){
                _ in
                if removeOverlay{
                    self.removeDropDownOverlay()
                }
        }
    }
    
    var products:[Product] = []
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultTableViewCell", forIndexPath: indexPath) as! SearchResultTableViewCell
        cell.tag = indexPath.row
        cell.setupCell(products[indexPath.row])
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showDetailForProduct(indexPath.row)
    }
    
    func showDetailForProduct(index:Int){
        let vc = ProductDetailTableViewController()
        vc.product = products[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

}
