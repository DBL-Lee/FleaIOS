//
//  VerifyCodeTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class VerifyCodeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var auxiBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        auxiBtn.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
        auxiBtn.setTitle("获取验证码", forState: .Normal)
    }
    
    func setupCell(title:String,placeholder:String){
        titleLabel.text = title
        textField.placeholder = placeholder
    }
    
}
