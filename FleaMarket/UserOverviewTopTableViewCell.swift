//
//  UserOverviewTopTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 20/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class UserOverviewTopTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView:UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var auxiLabel: UILabel!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nicknameLabel.text = ""
        locationLabel.text = ""
        auxiLabel.text = ""
    }
    
    func setupCell(avatar:String,nickname:String,gender: String?, location:String?,auxi:String?,productCount:Int,transaction:Int,goodFeedBack:Int){
        
        AvatarFactory.setupAvatarImageView(self.avatarImageView, avatar: avatar)
        
        self.nicknameLabel.text = nickname
        
        if gender != nil && location != nil {
            self.locationLabel.text = gender!+" | "+location!
        }else{
            if let gender = gender {
                self.locationLabel.text = gender
            }else if let location = location{
                self.locationLabel.text = location
            }
        }
        if let intro = auxi {
            self.auxiLabel.text = intro
        }else{
            self.auxiLabel.text = "这家伙什么也没留下"
        }
        
        self.label1.text = "\(productCount)\n全部宝贝"
        self.label2.text = "\(transaction)\n成功交易"
        self.label3.text = "\(goodFeedBack)\n好评次数"
    }
    
}
