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
    func setUpButton(name:String,icon:String){
        self.label.text = name
        self.label.font = UIFont.systemFontOfSize(12)
        self.label.sizeToFit()
        self.label.setNeedsLayout()
        
        self.imageView.image = nil
        
        if let image = UIImage(named: icon){
            self.imageView.image = image
        }else{
        
            let fileURL = LocalIconDirectory.URLByAppendingPathComponent(icon)
            if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){
                self.imageView.image = UIImage(contentsOfFile: fileURL.path!)!
            }else{
                RetrieveImageFromS3.retrieveCategoryIcon(icon){
                    print(NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!))
                    if (NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!)){
                        self.imageView.image = UIImage(contentsOfFile: fileURL.path!)!
                    }
                }
            }
        }
        
    }
}
