//
//  ImageViewWithBadge.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 03/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ImageViewWithBadge: UIView {
    var imageView:UIImageView!
    
    //negative means towards inside of image
    var centerOffset:CGPoint = CGPoint(x: -2, y: -4)
    
    var badgeView:TIPBadgeView?
    
    var rightConstraint:NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView = UIImageView(frame: CGRect(origin: CGPointZero, size: self.frame.size))
        self.addSubview(imageView)
        imageView.autoresizingMask = [.FlexibleHeight , .FlexibleWidth]
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.contentMode = .ScaleAspectFill
        
    }
    
    func addBadge(){
        let bv = TIPBadgeView()
        self.addSubview(bv)
        
        bv.translatesAutoresizingMaskIntoConstraints = false
        
        let badgeHeightConstraint = NSLayoutConstraint(item: bv, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 18.0)
        
        bv.addConstraints([badgeHeightConstraint])
        
        rightConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: bv, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 9.0-centerOffset.x)
        
        let topConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: bv, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 9.0+centerOffset.y)
        
        self.addConstraints([rightConstraint, topConstraint])
        
        self.badgeView = bv
    }
    
    func setBadgeValue(value : Int){
        if value > 0 {
            if self.badgeView == nil {
                addBadge()
            }
            self.badgeView!.setBadgeValue(value)
            rightConstraint.constant = self.badgeView!.frame.width/2-centerOffset.x
            self.badgeView!.layoutIfNeeded()
        } else {
            clearBadge()
        }
    }
    
    func clearBadge(){
        if self.badgeView != nil {
            self.badgeView!.removeFromSuperview()
            self.badgeView = nil
        }
    }
    
}
