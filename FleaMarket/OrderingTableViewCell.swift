//
//  OrderingTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class OrderingTableViewCell: UITableViewCell {

    @IBOutlet weak var orderButton: UIButton!
    
    var callback:()->Void = {}
    
    func setupCell(title:String,callback:()->Void){
        self.orderButton.setTitle(title, forState: .Normal)
        self.orderButton.addTarget(self, action: #selector(OrderingTableViewCell.tap), forControlEvents: .TouchUpInside)
        self.callback = callback
    }
    
    func tap(){
        callback()
    }
    
}
