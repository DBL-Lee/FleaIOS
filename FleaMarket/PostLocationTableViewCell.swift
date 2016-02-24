//
//  PostLocationTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PostLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    func setupCell(string:String){
        self.label.text = string
    }
    
    func setupCellWithAttributedText(string:NSAttributedString){
        self.label.attributedText = string
    }
}
