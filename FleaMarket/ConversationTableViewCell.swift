//
//  ConversationTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 29/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewWithBadge: ImageViewWithBadge!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMsgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let uuid = NSUUID().UUIDString
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(user:User,conversation:EMConversation){
        let avatar = user.avatar
        let title = user.nickname
        let lastMessage = conversation.latestMessage
        let time = NSDate.formattedTimeFromTimeInterval(lastMessage.timestamp)
        
        imageViewWithBadge.setBadgeValue(Int(conversation.unreadMessagesCount))
        
        AvatarFactory.setupAvatarImageView(self.imageViewWithBadge.imageView, avatar: avatar, square: true)
        
        self.titleLabel.text = title
        switch lastMessage.body.type{
        case EMMessageBodyTypeText:
            let body = lastMessage.body as! EMTextMessageBody
            self.lastMsgLabel.text = body.text
        default:
            break
        }
        
        self.timeLabel.text = time
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let color = UIColor.redColor()
        super.setSelected(selected, animated: animated)
        
//        TIPBadgeManager.sharedInstance.setBadgeValue(uuid, value: 0)
        
        if(selected) {
            for view in imageViewWithBadge.subviews{
                if view is TIPBadgeView{
                    view.backgroundColor = color
                }
            }
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = UIColor.redColor()
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            for view in imageViewWithBadge.subviews{
                if view is TIPBadgeView{
                    view.backgroundColor = color
                }
            }
        }
    }
        
}
