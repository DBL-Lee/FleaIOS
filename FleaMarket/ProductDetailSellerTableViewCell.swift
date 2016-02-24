//
//  ProductDetailSellerTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 04/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ProductDetailSellerTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var soldItemLabel: UILabel!
    @IBOutlet weak var feedBackRateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.contentMode = .ScaleAspectFill
    }

    func setupCell(avatar:UIImage,sellername:String,soldItemCount:Int,goodFeedBack:Int){
        self.avatarImageView.image = avatar
        self.userNameLabel.text = sellername
        self.soldItemLabel.text = "成功卖出\(soldItemCount)件二手商品"
        let res = goodFeedBack*10000/soldItemCount
        self.feedBackRateLabel.text = "好评率\(res/100).\(res%100)%"
    }
    
    
    @IBAction func contactSeller(sender: AnyObject) {
        
    }
}
