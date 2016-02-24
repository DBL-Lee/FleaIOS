//
//  PhotoChosenCollectionViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 27/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PhotoChosenCollectionViewCell: UICollectionViewCell {

    var handleTap:(Int)->Void = {_ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setupCell(image:UIImage,id:Int,callback:Int->Void,tapHandler:(Int)->Void){
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
        let view = ImageWithDeletionView(frame: self.contentView.frame, image: image, callback: callback, index: id)
        let tap = UITapGestureRecognizer(target: self, action: "tapped:")
        view.addGestureRecognizer(tap)
        self.contentView.addSubview(view)
        self.handleTap = tapHandler
    }

    func tapped(tap:UITapGestureRecognizer){
        let view = tap.view as! ImageWithDeletionView
        handleTap(view.index)
    }
}
