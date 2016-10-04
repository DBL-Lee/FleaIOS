//
//  ViewFeedbackTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 24/05/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ViewFeedbackTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var productLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(feedback:Feedback){
        AvatarFactory.setupAvatarImageView(self.avatarImageView, avatar: feedback.avatar)
        self.nicknameLabel.text = feedback.nickname
        self.feedbackLabel.text = feedback.content
        self.feedbackLabel.sizeToFit()
        
        var date = feedback.date
        var dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        var string = dateformatter.stringFromDate(date)
        string += " "+feedback.productTitle
        self.productLabel.text = string

        
        self.setNeedsLayout()
    }
    
    
    
}
