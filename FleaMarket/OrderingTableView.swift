//
//  OrderingTableView.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class OrderingTableView: UITableView,UITableViewDelegate,UITableViewDataSource{
    
    var callback:(FetchRequestSortType,String)->Void = {_,_ in }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        self.tableFooterView = UIView()
        self.registerNib(UINib(nibName: "OrderingTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderingTableViewCell")
    }
    
    let title = ["默认排序","最新发布","价格最低","价格最高","离我最近"]

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
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderingTableViewCell", forIndexPath: indexPath) as! OrderingTableViewCell
        cell.setupCell(title[indexPath.row], callback: {
            switch indexPath.row{
            case 0:self.callback(FetchRequestSortType.DEFAULT,self.title[0])
            case 1:self.callback(FetchRequestSortType.posttime,self.title[1])
            case 2:self.callback(FetchRequestSortType.price,self.title[2])
            case 3:self.callback(FetchRequestSortType.pricedesc,self.title[3])
            case 4:self.callback(FetchRequestSortType.distance,self.title[4])
            default:break
            }
        })
        return cell
    }
    

}
