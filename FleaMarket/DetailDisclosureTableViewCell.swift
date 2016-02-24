//
//  DetailDisclosureTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class DetailDisclosureTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.detailLabel.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
    }

    func setupCell(title:String,placeholder:String){
        self.label.text = title
        self.detailLabel.text = placeholder
    }
    
    func updateMessage(message:String){
        self.detailLabel.text = message
        self.detailLabel.textColor = UIColor.blackColor()
    }
    
}
