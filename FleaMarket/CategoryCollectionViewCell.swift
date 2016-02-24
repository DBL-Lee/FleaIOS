//
//  CategoryCollectionViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 22/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    func setUpButton(name:String){
        self.label.adjustsFontSizeToFitWidth = true
        self.label.text = name
        self.label.font = UIFont.systemFontOfSize(12)
        let im = UIImage(named: "电脑配件.png")!
        self.imageView.image = im
    }
}
