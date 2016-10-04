//
//  UserOverviewTopTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 20/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class UserOverviewTopTableViewCell: UITableViewCell {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var avatarImageView:UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var auxiLabel: UILabel!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    var tapCallback:String->Void = {_ in}
    var user:User!
    override func awakeFromNib() {
        super.awakeFromNib()
        nicknameLabel.text = ""
        locationLabel.text = ""
        auxiLabel.text = ""
        let white = UIColor.whiteColor().toImage()
        backImageView.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(white, diameter: UInt(backImageView.frame.width)).avatarImage
    }
    
    func setupCell(user:User,tapCallback:String->Void){
        self.user = user
        AvatarFactory.setupAvatarImageView(self.avatarImageView, avatar: user.avatar)
        
        self.nicknameLabel.text = user.nickname
        
        if user.gender != nil && user.location != nil {
            self.locationLabel.text = user.gender!+" | "+user.location!
        }else{
            if let gender = user.gender {
                self.locationLabel.text = gender
            }else if let location = user.location{
                self.locationLabel.text = location
            }else{
                self.locationLabel.text = ""
            }
        }
        if let intro = user.introduction {
            self.auxiLabel.text = intro
        }else{
            self.auxiLabel.text = "这家伙什么也没留下"
        }
        
        self.label1.text = "\(user.posted)\n全部宝贝"
        self.label2.text = "\(user.transaction)\n成功交易"
        self.label3.text = "\(user.goodfeedback)\n好评次数"
        
        self.tapCallback = tapCallback
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.cancelsTouchesInView = false
        self.avatarImageView.addGestureRecognizer(tap)
    }
    
    func tapped(){ //bug
        tapCallback(user.avatar)
    }

}
