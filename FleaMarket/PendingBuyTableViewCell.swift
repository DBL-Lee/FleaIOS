//
//  PendingBuyTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PendingBuyTableViewCell: UITableViewCell {

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var sellerAvatarImageView: UIImageView!
    
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var orderAmountLabel: UILabel!
    
    var confirmCallback:()->Void = {_ in}
    var cancelCallback:()->Void = {_ in}

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
    
    func setupCell(order:Order,cancelCallback:()->Void,confirmCallback:()->Void){
        AvatarFactory.setupAvatarImageView(sellerAvatarImageView, avatar: order.product.useravatar)
        AvatarFactory.setupNormalImageView(productImageView, image: order.product.imageUUID[order.product.mainimage])
        sellerNameLabel.text = order.product.usernickname
        productTitleLabel.text = order.product.title
        productTitleLabel.sizeToFit()
        productPriceLabel.text = order.product.getCurrentPriceWithCurrency()
        orderAmountLabel.text = "×\(order.amount)"
        
        self.cancelCallback = cancelCallback
        self.confirmCallback = confirmCallback
        
        self.statusLabel.text = order.status()
    }
    
    @IBAction func confirm(sender: AnyObject) {
        confirmCallback()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        cancelCallback()
    }
}
