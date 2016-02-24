//
//  FakeSearchBarButton.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class FakeSearchBarButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let attachment = NSTextAttachment()
        let im = UIImage(named: "search.png")!
        let height = self.frame.height*0.5
        let scale = height/im.size.height
        attachment.image = UIImage(CGImage: im.CGImage!, scale: 1/scale, orientation: .Up)
        let attachmentString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        let string = NSAttributedString(string: "  输入正在找的宝贝")
        attachmentString.appendAttributedString(string)
        self.setAttributedTitle(attachmentString, forState: .Normal)
        self.titleLabel?.textColor = UIColor.grayColor()
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
    }
}
