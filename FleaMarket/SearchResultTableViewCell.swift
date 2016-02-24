//
//  SearchResultTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageview.contentMode = .ScaleAspectFill
        imageview.clipsToBounds = true
    }
    
    var product:Product!
    
    func setupCell(product:Product){
        self.product = product
        
        let uuid = product.imageUUID[product.mainimage]
        RetrieveImageFromS3.retrieveImage(uuid, completion: {
            _ in
            self.imageview.image = UIImage(contentsOfFile: RetrieveImageFromS3.localDirectoryOf(uuid).path!)
        })
        
        //price attributed string
        let currentPrice = NSMutableAttributedString(string: product.getCurrentPriceWithCurrency()+" ")
        currentPrice.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSMakeRange(0, currentPrice.length))
        currentPrice.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: NSMakeRange(0, currentPrice.length))
        let usualPrice = NSMutableAttributedString(string: product.getOriginalPriceWithCurrency())
        usualPrice.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(0, usualPrice.length))
        usualPrice.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, usualPrice.length))
        usualPrice.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12), range: NSMakeRange(0, usualPrice.length))
        currentPrice.appendAttributedString(usualPrice)
        self.priceLabel.attributedText = currentPrice
        
        self.titleLabel.text = product.title
        
        self.locationLabel.text = product.getLocation()
    }

    
}
