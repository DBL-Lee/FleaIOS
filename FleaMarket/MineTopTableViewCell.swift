//
//  MineTopTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 18/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class MineTopTableViewCell: UITableViewCell {

    @IBOutlet weak var unloginLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var unloginBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        unloginBtn.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
        
    }

    func setupCell(){
        
    }
    
}
