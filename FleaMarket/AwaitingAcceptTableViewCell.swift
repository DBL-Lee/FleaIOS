//
//  AwaitingAcceptTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 16/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class AwaitingAcceptTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!

    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var awaitingCountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        productImageView.clipsToBounds = true
    }
    
    func setupCell(product:Product,awaitingCount:Int){
        AvatarFactory.setupAvatarImageView(self.productImageView, avatar: product.imageUUID[product.mainimage], square: true)
        self.titleLabel.text = product.title
        self.titleLabel.sizeToFit()
        self.amountLabel.text = "库存: \(product.amount-product.soldAmount)"
        self.awaitingCountLabel.text = "\(awaitingCount)个求购请求"
    }

    
    
}
