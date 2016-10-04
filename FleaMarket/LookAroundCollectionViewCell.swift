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
    var roundIndicator:KDCircularProgress!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageVIEW.contentMode = .ScaleAspectFill
        let progressView = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        progressView.startAngle = -90.0
        progressView.autoresizingMask = [.FlexibleTopMargin,.FlexibleBottomMargin,.FlexibleLeftMargin,.FlexibleRightMargin]
        progressView.setColors(UIColor.whiteColor())
        imageVIEW.addSubview(progressView)
        progressView.center = imageVIEW.center
        
        roundIndicator = progressView
    }
    
    func setupProgressIndicator(percentage:Int){
        roundIndicator.angle = Double(percentage)*360/100
        if percentage == 100 {
            roundIndicator.removeFromSuperview()
        }
    }
    
    func setImage(im:UIImage){
        self.roundIndicator.removeFromSuperview()
        self.imageVIEW.image = im
    }
}

