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
    var primaryTableView: UITableView!
    var secondaryTableView: UITableView!
    var primaryChosen = false
    var callback:Int->Void = {_ in}
    init(frame: CGRect, callback:Int->Void) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        primaryTableView = UITableView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        secondaryTableView = UITableView(frame: CGRect(x: 100, y: 0, width: frame.width-100, height: frame.height))
        secondaryTableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var primaryobjects:[NSManagedObject] = []
    var secondaryobjects:[[NSManagedObject]] = []
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        if tableView==primaryTableView{
            cell.textLabel?.text = primaryobjects[indexPath.row].valueForKey("title") as? String
            cell.selectedBackgroundView?.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }else{
            if let ip = primaryTableView.indexPathForSelectedRow {
                cell.textLabel?.text = secondaryobjects[ip.row][indexPath.row].valueForKey("title") as? String
            }else{
                cell.textLabel?.text = secondaryobjects[0][indexPath.row].valueForKey("title") as? String
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView==primaryTableView{
            return primaryobjects.count
        }
        if let ip = primaryTableView.indexPathForSelectedRow {
            return secondaryobjects[ip.row].count
        }
        return secondaryobjects[0].count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == primaryTableView {
            secondaryTableView.hidden = false
            secondaryTableView.reloadData()
        }else{
            callback(secondaryobjects[primaryTableView.indexPathForSelectedRow!.row][indexPath.row].valueForKey("id") as! Int)
        }
    }
    
}
