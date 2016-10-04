//
//  MessageBaseTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/06/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class MessageBaseTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: ImageViewWithBadge!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(text:String,image:UIImage){
        self.titleLabel.text = text
        self.iconImageView.imageView.image = image
    }
    
    func updateMessage(text:String,count:Int)
    {
        self.messageLabel.text = text
        iconImageView.setBadgeValue(count)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let color = UIColor.redColor()
        super.setSelected(selected, animated: animated)
        
        
        if(selected) {
            for view in iconImageView.subviews{
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
            for view in iconImageView.subviews{
                if view is TIPBadgeView{
                    view.backgroundColor = color
                }
            }
        }
    }
}
