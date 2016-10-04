//
//  MineTopTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 18/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MineTopTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var unloginLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var unloginBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        unloginBtn.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
        unloginBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        let square = UIImage(named: "defaultavatar.png")
        avatarImageView.image = JSQMessagesAvatarImageFactory.avatarImageWithImage(square, diameter: UInt(avatarImageView.frame.width)).avatarImage
        
    }
    
}
