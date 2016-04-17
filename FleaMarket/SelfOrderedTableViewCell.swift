//
//  SelfOrderedTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class SelfOrderedTableViewCell: UITableViewCell {

    @IBOutlet weak var changeAmtBtn: UIButton!
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var sellerAvatarImageView: UIImageView!

    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var orderAmountLabel: UILabel!
    
    override func awakeFromNib() {
        changeAmtBtn.layer.borderWidth = 1
        changeAmtBtn.layer.borderColor = UIColor.blackColor().CGColor
        changeAmtBtn.layer.cornerRadius = 3
        
        cancelOrderBtn.layer.borderWidth = 1
        cancelOrderBtn.layer.borderColor = UIColor.redColor().CGColor
        cancelOrderBtn.layer.cornerRadius = 3
        
        productPriceLabel.adjustsFontSizeToFitWidth = true
        
        sellerAvatarImageView.contentMode = .ScaleAspectFill
        sellerAvatarImageView.clipsToBounds = true
        productImageView.contentMode = .ScaleAspectFill
        productImageView.clipsToBounds = true
    }
    
    func setupCell(product:Product,amount:Int){
        AvatarFactory.setupAvatarImageView(sellerAvatarImageView, avatar: product.useravatar)
        AvatarFactory.setupAvatarImageView(productImageView, avatar: product.imageUUID[product.mainimage], square: true)
        sellerNameLabel.text = product.usernickname
        productTitleLabel.text = product.title
        productTitleLabel.sizeToFit()
        productPriceLabel.text = product.getCurrentPriceWithCurrency()
        orderAmountLabel.text = "×\(amount)"
    }
}
