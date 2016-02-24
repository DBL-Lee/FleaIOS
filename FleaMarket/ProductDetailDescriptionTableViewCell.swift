//
//  ProductDetailDescriptionTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 06/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ProductDetailDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.font = UIFont.systemFontOfSize(17)
    }

    func setupCell(text:String){
        self.textView.text = text
        let size = self.textView.sizeThatFits(CGSize(width: self.contentView.frame.width,height: CGFloat.max))
        heightConstraint.constant = size.height
        
    }
    
}
