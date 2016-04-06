//
//  LoginTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class LoginTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var auxiBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        auxiBtn.setBackgroundImage(UIImage(named: "password.png"), forState: .Normal)
        auxiBtn.setBackgroundImage(UIImage(named: "password-v.png"), forState: .Selected)
        auxiBtn.hidden = true
        textField.keyboardType = .ASCIICapable
    }
    
    func setSecureEntry(secure:Bool){
        UIView.performWithoutAnimation({
            var resumeFirstResponder = false
            if self.textField.isFirstResponder(){
                resumeFirstResponder = true
                self.textField.resignFirstResponder()
            }
            self.textField.secureTextEntry = secure
            if resumeFirstResponder{
                self.textField.becomeFirstResponder()
            }
            
        })
    }
    
    @IBAction func auxiBtnTapped(sender: AnyObject) {
        auxiBtn.selected = !auxiBtn.selected
        self.setSecureEntry(!auxiBtn.selected)
    }

    func setupCell(title:String,placeholder:String,showBtn:Bool){
        if showBtn{
            auxiBtn.hidden = false
            textField.secureTextEntry = true
        }
        titleLabel.text = title
        textField.placeholder = placeholder
    }
}
