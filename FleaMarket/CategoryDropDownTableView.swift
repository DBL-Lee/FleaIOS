//
//  CategoryDropDownTableView.swift
//  
//
//  Created by Zichuan Huang on 23/02/2016.
//
//

import UIKit
import CoreData

class CategoryDropDownTableView: UIView,UITableViewDelegate,UITableViewDataSource {
    /*
    Two tableviews one for primary and one for secondary
    The first cell in each tableview is 全部 which is handled separately
    Call back is (query is primarycategory?, id of primary/secondary category)
    */
    
    
    var primaryTableView: UITableView!
    var secondaryTableView: UITableView!
    var primaryChosen = false
    var callback:(Bool,Int,String)->Void = {_,_,_ in}
    init(frame: CGRect, callback:(Bool,Int,String)->Void) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        primaryTableView = UITableView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        secondaryTableView = UITableView(frame: CGRect(x: 100, y: 0, width: frame.width-100, height: frame.height))
        secondaryTableView.tableFooterView = UIView()
        primaryTableView.tableFooterView = UIView()
        self.addSubview(primaryTableView)
        self.addSubview(secondaryTableView)
        primaryTableView.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        secondaryTableView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        primaryTableView.delegate = self
        primaryTableView.dataSource = self
        secondaryTableView.delegate = self
        secondaryTableView.dataSource = self
        secondaryTableView.hidden = true
        primaryobjects = CoreDataHandler.instance.getPrimaryCategoryList()
        for p in primaryobjects{
            secondaryobjects.append(CoreDataHandler.instance.getSecondaryCategoryList(p))
        }
        primaryTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        secondaryTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.callback = callback
        self.grayBackground.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.whiteBackground.backgroundColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var primaryobjects:[NSManagedObject] = []
    var secondaryobjects:[[NSManagedObject]] = []
    let grayBackground = UIView()
    let whiteBackground = UIView()
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        if indexPath.row == 0{
            if tableView == primaryTableView{
                cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
                cell.selectedBackgroundView = whiteBackground
            }
            cell.textLabel?.text = "全部分类"
            cell.selectionStyle = .Default
        }else{
            let i = indexPath.row-1
            if tableView==primaryTableView{
                cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
                cell.textLabel?.text = primaryobjects[i].valueForKey("title") as? String
                cell.selectionStyle = .Default
                cell.selectedBackgroundView = whiteBackground
            }else{
                cell.backgroundView = whiteBackground
                cell.selectionStyle = .Default
                if let ip = primaryTableView.indexPathForSelectedRow {
                    cell.textLabel?.text = secondaryobjects[ip.row-1][i].valueForKey("title") as? String
                }else{
                    cell.textLabel?.text = secondaryobjects[0][i].valueForKey("title") as? String
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==primaryTableView{
            return primaryobjects.count+1
        }
        if let ip = primaryTableView.indexPathForSelectedRow {
            return secondaryobjects[ip.row-1].count+1
        }
        return secondaryobjects[0].count+1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == primaryTableView {
            if indexPath.row == 0{
                secondaryTableView.hidden = true
                callback(true,-1,"全部分类")
            }else{
                secondaryTableView.hidden = false
                secondaryTableView.reloadData()
            }
        }else{
            if indexPath.row == 0{
                callback(true,primaryobjects[primaryTableView.indexPathForSelectedRow!.row-1].valueForKey("id") as! Int,primaryobjects[primaryTableView.indexPathForSelectedRow!.row-1].valueForKey("title") as! String)
            }else{
                callback(false,secondaryobjects[primaryTableView.indexPathForSelectedRow!.row-1][indexPath.row-1].valueForKey("id") as! Int,secondaryobjects[primaryTableView.indexPathForSelectedRow!.row-1][indexPath.row-1].valueForKey("title") as! String)
            }
        }
    }
    
}
