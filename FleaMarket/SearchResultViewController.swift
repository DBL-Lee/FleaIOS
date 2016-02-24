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

class SearchResultViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPanel: UIView!

    @IBOutlet weak var categoryBtn: UIButton!
    let categoryText = "分类 "
    var categoryAttr:NSMutableAttributedString!
    var categoryAttrChosen:NSMutableAttributedString!
    
    var categoryView:CategoryDropDownTableView!
    
    @IBOutlet weak var sortBtn: UIButton!
    let sortText = "排序 "
    var sortAttr:NSMutableAttributedString!
    var sortAttrChosen:NSMutableAttributedString!
    @IBOutlet weak var filterBtn: UIButton!
    let filterText = "筛选 "
    var filterAttr:NSMutableAttributedString!
    var filterAttrChosen:NSMutableAttributedString!
    
    var searchController = UISearchController()
    
    @IBOutlet weak var dropDownOverlay:UIView!
    
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
    var searchText = ""
    
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
        let height:CGFloat = 30*0.5
        let scale = height/im.size.height
        downattachment.image = UIImage(CGImage: im.CGImage!, scale: 1/scale, orientation: .Up)
        let downAttr = NSAttributedString(attachment: downattachment)
        
        let upattachment = NSTextAttachment()
        let im2 = UIImage(named: "dropup.png")!
        upattachment.image = UIImage(CGImage: im2.CGImage!, scale: 1/scale, orientation: .Up)
        let upAttr = NSAttributedString(attachment: upattachment)
        
        categoryAttr = NSMutableAttributedString(string: categoryText)
        categoryAttrChosen = NSMutableAttributedString(string: categoryText)
        categoryAttr.appendAttributedString(downAttr)
        categoryAttrChosen.appendAttributedString(upAttr)
        
        sortAttr = NSMutableAttributedString(string: sortText)
        sortAttrChosen = NSMutableAttributedString(string: sortText)
        sortAttr.appendAttributedString(downAttr)
        sortAttrChosen.appendAttributedString(upAttr)
        
        
        filterAttr = NSMutableAttributedString(string: filterText)
        filterAttrChosen = NSMutableAttributedString(string: filterText)
        filterAttr.appendAttributedString(downAttr)
        filterAttrChosen.appendAttributedString(upAttr)
        
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
        
        categoryBtn.addTarget(self, action: "tapCategory", forControlEvents: .TouchUpInside)
        
        
        self.dropDownOverlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dropDownOverlay.clipsToBounds = true
    }
    
    var categorySubviewShowing = false
    func tapCategory(){
        if categorySubviewShowing{
            categorySubviewShowing = false
            removeCategorySubview()
        }else{
            categorySubviewShowing = true
            presentCategorySubview()
        }
    }

    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let vc = SearchViewController()
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
        button.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationController?.navigationBar.barTintColor = UIColor(white: 0.95, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        self.dropDownOverlay.hidden = true
        
        let height = dropDownOverlay.frame.height*0.8
        self.categoryView = CategoryDropDownTableView(frame: CGRect(x: 0, y: 0, width: dropDownOverlay.frame.width, height: height), callback: categoryChosen)
        categoryView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.categoryView.transform = CGAffineTransformMakeTranslation(0, -self.categoryView.frame.height)
        self.dropDownOverlay.addSubview(categoryView)
    }
    
    func dismiss(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        self.loadMore()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height-scrollView.frame.height
        if currentOffset/maximumOffset > 0.9 {
            loadMore()
        }
    }
    
    var loadingMore = false
    
    func loadMore(){
        if nextURL != "" && !loadingMore{
            //encode chinese characters
            nextURL = nextURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            loadingMore = true
            Alamofire.request(.GET, nextURL).responseJSON{
                response in
                switch response.result{
                case .Success:
                    let json = JSON(response.result.value!)
                    self.nextURL = json["next"].stringValue
                    for (_,productjson) in json["results"] {
                        self.products.append(Product.deserialize(productjson))
                    }
                    self.tableView.reloadData()
                    self.loadingMore = false
                case .Failure(let e):
                    print(e)
                }
            }
        }
    }
    
    func categoryChosen(id:Int){
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
        UIView.animateWithDuration(0.5, animations: {
            self.categoryView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func removeCategorySubview(){
        UIView.animateWithDuration(0.5, animations: {
            self.categoryView.transform = CGAffineTransformMakeTranslation(0, -self.categoryView.frame.height)
            }){
                _ in
                self.removeDropDownOverlay()
        }
    }
    
    func presentSortSubview(){
        
    }
    
    func presentFilterSubview(){
        
    }
    
    var products:[Product] = []
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultTableViewCell", forIndexPath: indexPath) as! SearchResultTableViewCell
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