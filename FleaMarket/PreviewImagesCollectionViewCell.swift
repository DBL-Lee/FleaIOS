//
//  PreviewImagesCollectionViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import KDCircularProgress

class PreviewImagesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    var roundIndicator:KDCircularProgress = KDCircularProgress()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView.contentMode = .ScaleAspectFit
        roundIndicator.startAngle = -90
        roundIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        roundIndicator.autoresizingMask = [.FlexibleTopMargin,.FlexibleBottomMargin,.FlexibleLeftMargin,.FlexibleRightMargin]
        roundIndicator.setColors(UIColor.whiteColor())
        imageView.addSubview(roundIndicator)
        roundIndicator.center = imageView.center
    }
    func setupCell(image:UIImage){
        self.roundIndicator.removeFromSuperview()
        self.imageView.image = image
    }
    func setupProgressIndicator(percentage:Int){
        roundIndicator.angle = percentage*360/100
        if percentage == 100 {
            roundIndicator.removeFromSuperview()
        }
    }
    
}
