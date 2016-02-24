//
//  PostAutoLocateTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PostAutoLocateTableViewCell: UITableViewCell {


    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageview.contentMode = .ScaleAspectFit
    }
    
    func setupCell(image:UIImage,string:String){
        self.imageview.image = image
        self.label.text = string
    }
}
