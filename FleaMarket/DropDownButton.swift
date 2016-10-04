//
//  DropDownButton.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 27/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

protocol DropDownButtonDelegate{
    func dropDownButtonTapped()
}

class DropDownButton: UIView {
    var imageView:UIImageView!
    var button:UILabel!
    var down = true
    var downImage:UIImage!
    var upImage:UIImage!
    var delegate:DropDownButtonDelegate!
    var containerView:UIView!
    var maxwidth:CGFloat = 0
    
    var labelWidthConstraint:NSLayoutConstraint!
    init(frame: CGRect,text:String) {
        super.init(frame: frame)
        containerView = UIView(frame: CGRect(origin: CGPointZero, size: frame.size))
        containerView.center = self.center
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        let heightC = NSLayoutConstraint(item: containerView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: -4)
        let centerY = NSLayoutConstraint(item: containerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraints([heightC,centerX,centerY])
        
        downImage = UIImage(named: "dropdown.png")!.imageWithRenderingMode(.AlwaysTemplate)
        upImage = UIImage(named: "dropup.png")!.imageWithRenderingMode(.AlwaysTemplate)
        
        imageView = UIImageView(image: downImage)
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        button = UILabel()
        
        
        button.text = text
        button.font = UIFont.systemFontOfSize(14)
        button.textColor = UIColor.whiteColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        button.userInteractionEnabled = false
        
        containerView.addSubview(button)
        containerView.addSubview(imageView)
        
        containerView.jsq_pinSubview(button, toEdge: .Leading)
        containerView.jsq_pinSubview(button, toEdge: .Top)
        containerView.jsq_pinSubview(button, toEdge: .Bottom)
        containerView.jsq_pinSubview(imageView, toEdge: .Trailing)
        
        let cons = NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: button, attribute: .Trailing, multiplier: 1, constant: 3)
        containerView.addConstraint(cons)
        
        
        let width = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15)
        let height = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 15)
        let centerV = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: containerView, attribute: .CenterY, multiplier: 1, constant: 0)
        imageView.addConstraints([width,height])
        containerView.addConstraint(centerV)
        
        maxwidth = frame.width-15
        
        labelWidthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: maxwidth)
        button.addConstraint(labelWidthConstraint)
        
        button.sizeToFit()
        if button.frame.width > maxwidth{
            labelWidthConstraint.constant = maxwidth
            button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: maxwidth, height: button.frame.height)
        }else{
            labelWidthConstraint.constant = button.frame.width
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tap)
    }
    
    func setlabel(text:String){
        self.button.text = text
        button.sizeToFit()
        if button.frame.width > maxwidth{
            labelWidthConstraint.constant = maxwidth
            button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y, width: maxwidth, height: button.frame.height)
        }else{
            labelWidthConstraint.constant = button.frame.width
        }
        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
    }
    
    func tapped(){
        //down = !down
        delegate.dropDownButtonTapped()
        if down{
            imageView.image = downImage
        }else{
            imageView.image = upImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
