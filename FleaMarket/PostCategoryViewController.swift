//
//  PostCategoryViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import CoreData

class PostCategoryViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var primaryCategory:[NSManagedObject] = []
    var secondaryCategory:[[NSManagedObject]] = []
    var callback:(String,String,Int)->Void = {_,_,_ in }
    
    @IBOutlet weak var mainCategoryTableView: UITableView!
    @IBOutlet weak var secondaryCategoryTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCategoryTableView.delegate = self
        mainCategoryTableView.dataSource = self
        secondaryCategoryTableView.delegate = self
        secondaryCategoryTableView.dataSource = self
        mainCategoryTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
        mainCategoryTableView.registerNib(UINib(nibName: "PostCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "PostCategoryTableViewCell")
        mainCategoryTableView.backgroundColor = UIColor.lightGrayColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        secondaryCategoryTableView.registerNib(UINib(nibName: "PostCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "PostCategoryTableViewCell")
        
        self.primaryCategory = CoreDataHandler.instance.getPrimaryCategoryList()
        for primary in primaryCategory{
            secondaryCategory.append(CoreDataHandler.instance.getSecondaryCategoryList(primary))
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mainCategoryTableView{
            return primaryCategory.count
        }else{
            return secondaryCategory[mainCategoryTableView.indexPathForSelectedRow!.row].count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCategoryTableViewCell", forIndexPath: indexPath) as! PostCategoryTableViewCell
        if tableView==mainCategoryTableView{
            cell.setupCell(self.primaryCategory[indexPath.row].valueForKey("title") as! String)
        }else{
            cell.setupCell(secondaryCategory[mainCategoryTableView.indexPathForSelectedRow!.row][indexPath.row].valueForKey("title") as! String)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == mainCategoryTableView {
            secondaryCategoryTableView.reloadData()
        }else{
            callback(primaryCategory[mainCategoryTableView.indexPathForSelectedRow!.row].valueForKey("title") as! String,secondaryCategory[mainCategoryTableView.indexPathForSelectedRow!.row][indexPath.row].valueForKey("title") as! String, secondaryCategory[mainCategoryTableView.indexPathForSelectedRow!.row][indexPath.row].valueForKey("id") as! Int)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    

}
