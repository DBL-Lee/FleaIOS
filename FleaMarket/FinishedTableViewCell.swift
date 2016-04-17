//
//  FinishedTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class FinishedTableViewCell: UITableViewCell {

    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var sellerAvatarImageView: UIImageView!
    
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var orderAmountLabel: UILabel!
    
    var rateCallback:()->Void = {_ in}
    
    override func awakeFromNib() {
        
        rateBtn.layer.borderWidth = 1
        rateBtn.layer.borderColor = UIColor.redColor().CGColor
        rateBtn.layer.cornerRadius = 3
        
        productPriceLabel.adjustsFontSizeToFitWidth = true
        
        sellerAvatarImageView.contentMode = .ScaleAspectFill
        sellerAvatarImageView.clipsToBounds = true
        productImageView.contentMode = .ScaleAspectFill
        productImageView.clipsToBounds = true
    }
    
    func setupCell(product:Product,amount:Int,nickname:String,avatar:String,rateCallback:()->Void){
        AvatarFactory.setupAvatarImageView(sellerAvatarImageView, avatar: avatar)
        AvatarFactory.setupAvatarImageView(productImageView, avatar: product.imageUUID[product.mainimage], square: true)
        sellerNameLabel.text = nickname
        productTitleLabel.text = product.title
        productTitleLabel.sizeToFit()
        productPriceLabel.text = product.getCurrentPriceWithCurrency()
        orderAmountLabel.text = "×\(amount)"
        
        self.rateCallback = rateCallback
    }
    @IBAction func rateBtnPressed(sender: AnyObject) {
        self.rateCallback()
    }
}
