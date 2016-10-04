//
//  PreviewImagesCollectionViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PreviewImagesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    var roundIndicator:KDCircularProgress!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView.contentMode = .ScaleAspectFit
        let progressView = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        progressView.startAngle = -90.0
        progressView.autoresizingMask = [.FlexibleTopMargin,.FlexibleBottomMargin,.FlexibleLeftMargin,.FlexibleRightMargin]
        progressView.setColors(UIColor.whiteColor())
        imageView.addSubview(progressView)
        progressView.center = imageView.center
        
        roundIndicator = progressView
    }
    func setupCell(image:UIImage){
        self.roundIndicator.removeFromSuperview()
        self.imageView.image = image
    }
    func setupProgressIndicator(percentage:Int){
        roundIndicator.angle = Double(percentage)*360/100
        if percentage == 100 {
            roundIndicator.removeFromSuperview()
        }
    }
    
}
