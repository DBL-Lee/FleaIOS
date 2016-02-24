//
//  ProductDetailTitleTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 04/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ProductDetailTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLabel.font = UIFont.boldSystemFontOfSize(20)
        self.titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setupCell(title:String,price:String,originalprice:String,location:String){
        self.titleLabel.text = title
        let attrprice = NSMutableAttributedString(string: price)
        attrprice.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSMakeRange(0, price.characters.count))
        attrprice.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(20), range: NSMakeRange(0, price.characters.count))
        if originalprice != ""{
            let attroriginal = NSAttributedString(string: "  原价:  ", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(10)])
            let attroriginalprice = NSAttributedString(string: originalprice, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(10),NSStrikethroughStyleAttributeName:1])
            attrprice.appendAttributedString(attroriginal)
            attrprice.appendAttributedString(attroriginalprice)
        }
        self.priceLabel.attributedText = attrprice
        
        self.locationLabel.text = location
        self.locationLabel.font = UIFont.systemFontOfSize(10)
    }
    
}
