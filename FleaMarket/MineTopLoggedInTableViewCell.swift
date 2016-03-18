//
//  MineTopLoggedInTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 18/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class MineTopLoggedInTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var auxiLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.contentMode = .ScaleAspectFill
    }
    
    func setupCell(avatar:String,nickname:String,auxistr:String = ""){
        let fileURL = RetrieveImageFromS3.localDirectoryOf(avatar)
        if avatar == "default"{
            self.avatarImageView.image = UIImage(named:"defaultavatar.png")
        }else if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){
            self.avatarImageView.image = UIImage(contentsOfFile: fileURL.path!)!
        }else{
            RetrieveImageFromS3.retrieveImage(avatar, bucket: S3ImagesBucketName){
                self.avatarImageView.image = UIImage(contentsOfFile: fileURL.path!)!
            }
        }
        self.nicknameLabel.text = nickname
        self.auxiLabel.text = auxistr
    }

    
    
    
}
