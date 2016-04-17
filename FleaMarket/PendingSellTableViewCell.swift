//
//  PendingSellTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PendingSellTableViewCell: UITableViewCell {

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var sellerAvatarImageView: UIImageView!
    
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var orderAmountLabel: UILabel!
    
    override func awakeFromNib() {
        confirmBtn.layer.borderWidth = 1
        confirmBtn.layer.borderColor = UIColor.blackColor().CGColor
        confirmBtn.layer.cornerRadius = 3
        
        cancelOrderBtn.layer.borderWidth = 1
        cancelOrderBtn.layer.borderColor = UIColor.redColor().CGColor
        cancelOrderBtn.layer.cornerRadius = 3
        
        productPriceLabel.adjustsFontSizeToFitWidth = true
        
        sellerAvatarImageView.contentMode = .ScaleAspectFill
        sellerAvatarImageView.clipsToBounds = true
        productImageView.contentMode = .ScaleAspectFill
        productImageView.clipsToBounds = true
    }
    
    func setupCell(product:Product,amount:Int,buyernickname:String,buyeravatar:String){
        AvatarFactory.setupAvatarImageView(sellerAvatarImageView, avatar: buyeravatar)
        AvatarFactory.setupAvatarImageView(productImageView, avatar: product.imageUUID[product.mainimage], square: true)
        sellerNameLabel.text = buyernickname
        productTitleLabel.text = product.title
        productTitleLabel.sizeToFit()
        productPriceLabel.text = product.getCurrentPriceWithCurrency()
        orderAmountLabel.text = "×\(amount)"
    }
    
}
