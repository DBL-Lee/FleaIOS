//
//  AvatarEditTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 03/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class AvatarEditTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.contentMode = .ScaleAspectFill
        avatarImageView.clipsToBounds = true
    }

    func setupCell(title:String,avatar:String){
        self.titleLabel.text = title
        AvatarFactory.setupAvatarImageView(avatarImageView, avatar: avatar, square: true)
    }
    
}
