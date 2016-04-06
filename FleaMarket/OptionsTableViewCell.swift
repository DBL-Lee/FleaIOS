//
//  OptionsTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 31/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    var callback:Int->Void = {_ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button1.layer.borderWidth = 1
        self.button1.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.button2.layer.borderWidth = 1
        self.button2.layer.borderColor = UIColor.lightGrayColor().CGColor
        let image = UIColor.orangeColor().toImage()
        self.button1.setBackgroundImage(image, forState: .Selected)
        self.button1.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.button1.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.button2.setBackgroundImage(image, forState: .Selected)
        self.button2.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.button2.setTitleColor(UIColor.whiteColor(), forState: .Selected)
    }
    
    func setupCell(title:String,button1title:String,button2title:String,callback:Int->Void){
        self.titleLabel.text = title
        self.button1.setTitle(button1title, forState: .Normal)
        self.button2.setTitle(button2title, forState: .Normal)
        self.callback = callback
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if !sender.selected{
            self.button1.selected = false
            self.button2.selected = false
            sender.selected = true
        }else{
            sender.selected = false
        }
        if button1.selected{
            callback(1)
        }else if button2.selected{
            callback(2)
        }else{
            callback(0)
        }
    }

    
}
