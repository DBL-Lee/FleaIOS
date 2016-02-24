//
//  LookAroundCollectionViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 23/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class LookAroundCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageVIEW: UIImageView!
    var index = 0
    
    func setImage(im:UIImage){
        self.imageVIEW.contentMode = .ScaleAspectFill
        self.imageVIEW.image = im
    }
}
