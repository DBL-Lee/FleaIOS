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
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var orderAmountLabel: UILabel!
    
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
    
    func setupCell(order:Order,cancelCallback:()->Void){
        AvatarFactory.setupAvatarImageView(sellerAvatarImageView, avatar: order.buyeravatar)
        AvatarFactory.setupNormalImageView(productImageView, image: order.product.imageUUID[order.product.mainimage])
        sellerNameLabel.text = order.buyernickname
        productTitleLabel.text = order.product.title
        productTitleLabel.sizeToFit()
        productPriceLabel.text = order.product.getCurrentPriceWithCurrency()
        orderAmountLabel.text = "×\(order.amount)"
        
        self.statusLabel.text = order.status()
        
        self.cancelCallback = cancelCallback
    }
    
    @IBAction func cancel(sender: AnyObject) {
        cancelCallback()
    }
}
