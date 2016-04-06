//
//  FilterDropDownTableView.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//
import UIKit

class FilterDropDownTableView:UITableView,UITableViewDataSource,UITableViewDelegate{
    var pricecell:DoubleDragPriceTableViewCell!
    var distanceCell:DistanceDragCell!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60))
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: frame.width-20, height: 40)
        button.setTitle("确定", forState: .Normal)
        button.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
        button.tintColor = UIColor.whiteColor()
        button.addTarget(self, action: #selector(FilterDropDownTableView.confirm), forControlEvents: .TouchUpInside)
        view.addSubview(button)
        button.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        button.center = view.center
        self.tableFooterView = view
        self.registerNib(UINib(nibName: "ToggleSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "ToggleSwitchTableViewCell")
        self.registerNib(UINib(nibName: "DoubleDragPriceTableViewCell", bundle: nil), forCellReuseIdentifier: "DoubleDragPriceTableViewCell")
        self.registerNib(UINib(nibName: "DistanceDragCell", bundle: nil), forCellReuseIdentifier: "DistanceDragCell")
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 44
        self.alwaysBounceVertical = false
        self.delegate = self
        self.dataSource = self
        
        pricecell = self.dequeueReusableCellWithIdentifier("DoubleDragPriceTableViewCell") as! DoubleDragPriceTableViewCell
        pricecell.selectionStyle = .None
        distanceCell = self.dequeueReusableCellWithIdentifier("DistanceDragCell") as! DistanceDragCell
        distanceCell.selectionStyle = .None
        
    }
    var brandNew = false
    var bargain = false
    var exchange = false
    
    var callback:(Bool,Bool,Bool,Int?,Int?,Int?)->Void = {_,_,_,_,_,_ in}
    
    func confirm(){
        self.endEditing(true)
        var lower:Int? = nil
        var upper:Int? = nil
        var distance:Int? = nil
        if pricecell.lowerInt != 0 {
            lower = pricecell.lowerInt
        }
        if pricecell.upperInt != Int(pricecell.maximum){
            upper = pricecell.upperInt
        }
        if distanceCell.distance != distanceCell.maxDistance{
            distance = distanceCell.distance
        }
        callback(brandNew,bargain,exchange,distance,lower,upper)
    }

    func toggleBrandnew(flag:Bool){
        brandNew = flag
    }
    func toggleBargain(flag:Bool){
        bargain = flag
    }
    func toggleExchange(flag:Bool){
        exchange = flag
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func needsShowing(){
        self.setNeedsLayout()
        self.sizeToFit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("ToggleSwitchTableViewCell", forIndexPath: indexPath) as! ToggleSwitchTableViewCell
            cell.setupCell("只看全新", callback: toggleBrandnew)
            cell.selectionStyle = .None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ToggleSwitchTableViewCell", forIndexPath: indexPath) as! ToggleSwitchTableViewCell
            cell.setupCell("同意讲价", callback: toggleBargain)
            cell.selectionStyle = .None
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("ToggleSwitchTableViewCell", forIndexPath: indexPath) as! ToggleSwitchTableViewCell
            cell.setupCell("同意置换", callback: toggleExchange)
            cell.selectionStyle = .None
            return cell
        case 3:
            return distanceCell
        case 4:
            return pricecell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.endEditing(true)
    }
}