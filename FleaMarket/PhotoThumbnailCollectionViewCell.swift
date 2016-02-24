//
//  PhotoThumbnailCollectionViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 26/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PhotoThumbnailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var chosenBtn: UIButton!
    
    var id = 0
    var callback:Int->Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.contentMode = .ScaleAspectFill
        self.imgView.clipsToBounds = true
        self.contentView.backgroundColor = UIColor.redColor()
        self.chosenBtn.setBackgroundImage(UIImage(named: "uncheckmark.png"), forState: .Normal)
        self.chosenBtn.setBackgroundImage(UIImage(named: "checkmark.png"), forState: .Selected)
        let tapGesture = UITapGestureRecognizer(target: self, action: "chosenBtnClicked")
        self.addGestureRecognizer(tapGesture)
    }
    
    func chosenBtnClicked() {
        callback(id)
    }
    
    
    func setThumbnailImage(thumbnailImage: UIImage,selected:Bool, id:Int,callback:Int->Void){
        self.chosenBtn.selected = selected
        self.imgView.image = thumbnailImage
        self.id = id
        self.callback = callback
    }
}
