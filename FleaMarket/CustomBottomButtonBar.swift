//
//  CustomBottomButtonBar.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 03/05/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

protocol  CustomBottomButtonBarDelegate {
    func didPressButton(index:Int)
}

class CustomBottomButtonBar: UIView {

    var buttons:[UIButton] = []
    var delegate:CustomBottomButtonBarDelegate?
    let separatorColor:UIColor = UIColor.lightGrayColor()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBorder(edges: .Top, colour: UIColor.lightGrayColor(), thickness: 0.5)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addButtons(buttons:[String]){
        if self.buttons.count > 0{
            return
        }
        if buttons.count == 0 {
            return
        }
        
        for i in 0..<buttons.count{ //add constraints
            var leadC:NSLayoutConstraint!
            let currentButton = UIButton(type: .Custom)
            currentButton.setTitle(buttons[i], forState: .Normal)
            currentButton.titleLabel?.font = UIFont.systemFontOfSize(14)
            currentButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            
            currentButton.titleLabel?.adjustsFontSizeToFitWidth = true
            currentButton.addTarget(self, action: #selector(btnPressed), forControlEvents: .TouchUpInside)
            self.addSubview(currentButton)
            self.buttons.append(currentButton)
            currentButton.translatesAutoresizingMaskIntoConstraints = false
            if i==0{
                leadC = NSLayoutConstraint(item: currentButton, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
            }else{
                let previousButton = self.buttons[i-1]
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = separatorColor
                self.addSubview(separator)
                let sWidthC = NSLayoutConstraint(item: separator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0.5)
                let sHeightC = NSLayoutConstraint(item: separator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
                separator.addConstraints([sWidthC,sHeightC])
                let sHorizontalC = NSLayoutConstraint(item: separator, attribute: .CenterY, relatedBy: .Equal, toItem: previousButton, attribute: .CenterY, multiplier: 1, constant: 0)
                let sVerticalC = NSLayoutConstraint(item: separator, attribute: .Leading, relatedBy: .Equal, toItem: previousButton, attribute: .Trailing, multiplier: 1, constant: 0)
                self.addConstraints([sHorizontalC,sVerticalC])
                
                leadC = NSLayoutConstraint(item: currentButton, attribute: .Leading, relatedBy: .Equal, toItem: separator, attribute: .Trailing, multiplier: 1, constant: 0)
                
                
                let equalwidthC = NSLayoutConstraint(item: currentButton, attribute: .Width, relatedBy: .Equal, toItem: previousButton, attribute: .Width, multiplier: 1, constant: 0)
                self.addConstraint(equalwidthC)
            }
            let topC = NSLayoutConstraint(item: currentButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            let btmC = NSLayoutConstraint(item: currentButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            self.addConstraints([leadC,topC,btmC])
        }
        let lastBtn = self.buttons.last!
        let trailingC = NSLayoutConstraint(item: lastBtn, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        self.addConstraint(trailingC)
        
        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
       
    }
    
    func btnPressed(button:UIButton){
        let index = buttons.indexOf(button)!
        
        delegate?.didPressButton(index)
        
    }
    
    func setTitleOfButton(index:Int,title:String){
        buttons[index].setTitle(title, forState: .Normal)
    }
        

}
