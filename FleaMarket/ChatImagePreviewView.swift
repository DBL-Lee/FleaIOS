//
//  ChatImagePreviewView.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 09/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ChatImagePreviewView: UIView {
    var imageView:UIImageView!
    init(image:UIImage){
        super.init(frame: CGRectZero)
        imageView = UIImageView(frame: self.frame)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        self.addSubview(imageView)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(remove)))
        
        imageView.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        self.backgroundColor = UIColor.blackColor()
    }
    
    func remove(tap:UIGestureRecognizer){
        self.removeFromSuperview()
    }
    
    func setImage(image:UIImage){
        self.imageView.image = image
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
