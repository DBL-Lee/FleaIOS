//
//  FollowerFollowingTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 09/05/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class FollowerFollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var introLabel: UILabel!
    
    var buttonCallback:()->Void = {}
    var user:FollowPeople!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.contentMode = .ScaleAspectFill

        followButton.addTarget(self, action: #selector(followTapped), forControlEvents: .TouchUpInside)
    }
    
    func setupCell(user:FollowPeople, callback:()->Void){
        AvatarFactory.setupAvatarImageView(self.avatarImageView, avatar: user.avatar)
        self.titleLabel.text = user.name
        
        self.user = user
        if user.gender != nil && user.location != nil {
            self.infoLabel.text = user.gender! + "|" + user.location!
        }else if let gender = user.gender{
            self.infoLabel.text = gender
        }else if let location = user.location{
            self.infoLabel.text = location
        }else{
            self.infoLabel.text = ""
        }
        if let intro = user.introduction{
            self.introLabel.text = intro
        }else{
            self.introLabel.text = ""
        }
        if !user.followed{
            let image = UIImage(named: "followno.png")?.imageWithRenderingMode(.AlwaysTemplate)
            followButton.setImage(image, forState: .Normal)
            followButton.tintColor = UIColor.orangeColor()
        }else{
            let image = UIImage(named: "followyes.png")?.imageWithRenderingMode(.AlwaysTemplate)
            followButton.setImage(image, forState: .Normal)
            followButton.tintColor = UIColor.grayColor()
        }
        self.buttonCallback = callback
    }
    
    func followTapped(){
        buttonCallback()
    }
    

    
    
}
