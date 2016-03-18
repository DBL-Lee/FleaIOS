//
//  ToggleSwitchTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ToggleSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var callback:Bool->Void = {_ in}
    
    @IBAction func switchToggled(sender: UISwitch) {
        callback(sender.on)
    }

    func setupCell(title:String,callback:Bool->Void){
        self.titleLabel.text = title
        self.callback = callback
    }
}
