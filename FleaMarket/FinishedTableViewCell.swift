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
    
    @IBOutlet weak var statusLabel: UILabel!
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
    
    func setupCell(order:Order,rateCallback:()->Void){
        let imseller:Bool = order.product.userid == UserLoginHandler.instance.userid
        AvatarFactory.setupAvatarImageView(sellerAvatarImageView, avatar: imseller ? order.buyeravatar : order.product.useravatar)
        AvatarFactory.setupAvatarImageView(productImageView, avatar: order.product.imageUUID[order.product.mainimage], square: true)
        sellerNameLabel.text = imseller ? order.buyernickname : order.product.usernickname
        productTitleLabel.text = order.product.title
        productTitleLabel.sizeToFit()
        productPriceLabel.text = order.product.getCurrentPriceWithCurrency()
        orderAmountLabel.text = "×\(order.amount)"
        
        self.statusLabel.text = order.status()
        
        self.rateCallback = rateCallback
        
        if order.notfeedbacked(){
            rateBtn.hidden = false
        }else{
            rateBtn.hidden = true
        }
    }
    @IBAction func rateBtnPressed(sender: AnyObject) {
        self.rateCallback()
    }
}
