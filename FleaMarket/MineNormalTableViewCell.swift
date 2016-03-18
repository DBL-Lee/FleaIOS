//
//  MineNormalTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 18/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class MineNormalTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(title:String,count:Int? = nil){
        self.titleLabel.text = title
        if let count = count{
            self.countLabel.text = "\(count)"
        }else{
            self.countLabel.text = ""
        }
    }
    
}
