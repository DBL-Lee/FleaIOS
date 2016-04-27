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

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var orderAmountLabel: UILabel!
    
    var cancelCallback:()->Void = {_ in}
    var changeAmtCallback:()->Void = {_ in}
    
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
        
        statusLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setupCell(order:Order,changeAmtCallback:()->Void,cancelCallback:()->Void){
        let product = order.product
        AvatarFactory.setupAvatarImageView(sellerAvatarImageView, avatar: product.useravatar)
        AvatarFactory.setupNormalImageView(productImageView, image: product.imageUUID[product.mainimage])
        
        
        sellerNameLabel.text = product.usernickname
        productTitleLabel.text = product.title
        productTitleLabel.sizeToFit()
        productPriceLabel.text = product.getCurrentPriceWithCurrency()
        
        if !order.ongoing {
            changeAmtBtn.hidden = true
            cancelOrderBtn.hidden = true
        }else{
            changeAmtBtn.hidden = false
            cancelOrderBtn.hidden = false
            
        }
        
        orderAmountLabel.text = "×\(order.amount)"
        
        self.statusLabel.text = order.status()
        
        self.changeAmtCallback = changeAmtCallback
        self.cancelCallback = cancelCallback
    }
    @IBAction func changeAmt(sender: AnyObject) {
        changeAmtCallback()
    }
    @IBAction func cancel(sender: AnyObject) {
        cancelCallback()
    }
}
