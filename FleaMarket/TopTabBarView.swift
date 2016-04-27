//
//  TopTabBarView.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

protocol TopTabBarViewDelegate {
    func didChangeToButtonNumber(number:Int)
}

class TopTabBarView: UIView {
    var buttons:[UIButton] = []
    var delegate:TopTabBarViewDelegate?
    var bar:UIView!
    var centerConstraint:NSLayoutConstraint!
    var currentSelected:Int = 0
    var selectedColor:[UIColor] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBorder(edges: .Bottom, colour: UIColor.lightGrayColor(), thickness: 0.5)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addButtons(buttons:[String], colors:[UIColor] = []){
        if self.buttons.count > 0{
            return
        }
        if buttons.count == 0 {
            return
        }
        var selectedColors:[UIColor] = colors
        if colors.count == 0{
            selectedColors = [UIColor](count: buttons.count, repeatedValue: UIColor.orangeColor())
        }
        self.selectedColor = selectedColors
        
        for i in 0..<buttons.count{ //add constraints
            var leadC:NSLayoutConstraint!
            let currentButton = UIButton(type: .Custom)
            currentButton.setTitle(buttons[i], forState: .Normal)
            currentButton.titleLabel?.font = UIFont.systemFontOfSize(14)
            currentButton.setTitleColor(selectedColors[i], forState: .Selected)
            currentButton.setTitleColor(selectedColors[i], forState: .Highlighted)
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
                leadC = NSLayoutConstraint(item: currentButton, attribute: .Leading, relatedBy: .Equal, toItem: previousButton, attribute: .Trailing, multiplier: 1, constant: 0)
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
        
        bar = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 2))
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = selectedColors[0]
        self.addSubview(bar)
        
        let constraint = NSLayoutConstraint(item: bar, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        centerConstraint = NSLayoutConstraint(item: bar, attribute: .CenterX, relatedBy: .Equal, toItem: self.buttons.first!, attribute: .CenterX, multiplier: 1, constant: 0)
        let widthC = NSLayoutConstraint(item: bar, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 60)
        let heightC = NSLayoutConstraint(item: bar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 2)
        self.addConstraints([constraint,centerConstraint,widthC,heightC])
        
        self.buttons.first!.selected = true
    }
    
    func btnPressed(button:UIButton){
        if button.selected{
            return
        }
        for btn in self.buttons{
            btn.selected = false
        }
        button.selected = true
        let index = buttons.indexOf(button)!
        
        delegate?.didChangeToButtonNumber(index)
        currentSelected = index
        
        moveBarTo(index)
    }
    
    func moveBarTo(index:Int){
        self.layoutIfNeeded()
        self.removeConstraint(centerConstraint)
        centerConstraint = NSLayoutConstraint(item: bar, attribute: .CenterX, relatedBy: .Equal, toItem: buttons[index], attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(centerConstraint)
        UIView.animateWithDuration(0.5, animations: {
            self.bar.backgroundColor = self.selectedColor[index]
            self.layoutIfNeeded()
        })
    }

}
