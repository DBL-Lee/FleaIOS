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
        imageView = UIImageView(frame: CGRectZero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        self.addSubview(imageView)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(remove)))
        
        self.jsq_pinSubview(imageView, toEdge: .Leading)
        self.jsq_pinSubview(imageView, toEdge: .Trailing)
        let topC = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 50)
        let btmC = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 50)
        self.addConstraints([topC,btmC])
        
        self.backgroundColor = UIColor.blackColor()
    }
    
    func remove(tap:UIGestureRecognizer){
        UIView.animateWithDuration(0.5, animations: {
            self.alpha = 0
            }, completion: {
                success in
                self.removeFromSuperview()
        })
    }
    
    func setImage(image:UIImage){
        self.imageView.image = image
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
