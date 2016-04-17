//
//  AwaitingPeopleTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 16/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class AwaitingPeopleTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var callback:()->Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        acceptBtn.layer.borderColor = UIColor.blackColor().CGColor
        acceptBtn.layer.borderWidth = 1
        acceptBtn.layer.cornerRadius = 3
    }
    
    func setupCell(avatar:String,nickname:String,amount:Int,text:String = "",callback:()->Void){
        AvatarFactory.setupAvatarImageView(self.avatarImageView, avatar: avatar, square: false)
        self.nameLabel.text = nickname
        self.amountLabel.text = "求购数量: \(amount)"
        self.infoLabel.text = text
        self.infoLabel.sizeToFit()
        self.callback = callback
    }
    @IBAction func acceptClicked(sender: AnyObject) {
        callback()
    }
    
}
