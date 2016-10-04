//
//  CustomInputToolBar.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 06/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import JSQMessagesViewController

protocol CustomInputToolBarDelegate{
    func toolBarDidMoveUp(height:CGFloat)
}
class CustomInputToolBar: JSQMessagesInputToolbar,JSQMessagesInputToolbarDelegate {
    var rightButtons:[CustomToolBarButton] = []
    var customDelegate:CustomInputToolBarDelegate!
    var recordButton:UIButton!
    var assViewHeight:CGFloat = 220
    
    weak var chatVC:ChatViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidChange), name: UIKeyboardWillChangeFrameNotification, object: nil)
        recordButton = UIButton(type: .Custom)
        //recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.frame = self.contentView.textView.bounds
        recordButton.setTitle("按住说话", forState: .Normal)
        recordButton.setTitle("松开发送", forState: .Highlighted)
        recordButton.setBackgroundImage(UIColor.groupTableViewBackgroundColor().toImage(), forState: .Normal)
        recordButton.titleLabel!.font = UIFont.systemFontOfSize(15)
        recordButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.8), forState: .Normal)
        self.contentView.textView.addSubview(recordButton)
        
        recordButton.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        recordButton.hidden = true
        self.contentView.textView.clipsToBounds = true
        self.contentView.textView.font = UIFont.systemFontOfSize(15)
        self.needsUpdateConstraints()
    }
    
    func keyboardDidChange(notification:NSNotification){
        
        let userinfo = notification.userInfo!
        let beginframe = userinfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let endframe = userinfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let duration = userinfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        let curve = userinfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let option = UIViewAnimationOptions(rawValue: UInt(curve))
        let keyboardheight = endframe.height
        
        if endframe.minY < beginframe.minY { // move up
            for btn in rightButtons{
                btn.selected = false
            }
            barisUp = false
            keyboardisUp = true
            let newHeight = self.frame.maxY-(keyboardheight-displacement)
            moveBarToHeight(newHeight,option: option, fromKeyboard: true){
                for button in self.rightButtons{
                    button.associatedView.hidden = true
                }
            }
        }else{ // move down
            if !barisUp{
                for btn in rightButtons{
                    btn.selected = false
                }
                moveBarToHeight(self.frame.maxY+displacement,option: option,fromKeyboard: true){
                    self.keyboardisUp = false
                    for button in self.rightButtons{
                        button.associatedView.hidden = true
                    }
                }
            }
        }
        
        
    }
    
    func addButtonToRightBar(button:CustomToolBarButton){
        
        button.addTarget(self, action: #selector(moveBarUp(_:)), forControlEvents: .TouchUpInside)
        
        if rightButtons.count == 0{
            button.frame = self.contentView.rightBarButtonContainerView.bounds
            self.contentView.rightBarButtonContainerView.hidden = false
            self.contentView.rightBarButtonItemWidth = self.contentView.rightBarButtonContainerView.bounds.height + 8
            button.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.rightBarButtonContainerView.addSubview(button)
            let oneoneconstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Height, multiplier: 1, constant: 0)
            button.addConstraint(oneoneconstraint)
            
            self.contentView.rightBarButtonContainerView.jsq_pinSubview(button, toEdge: .Top)
            self.contentView.rightBarButtonContainerView.jsq_pinSubview(button, toEdge: .Bottom)
            
            let trailingC = NSLayoutConstraint(item: self.contentView.rightBarButtonContainerView, attribute: .Trailing, relatedBy: .Equal, toItem: button, attribute: .Trailing, multiplier: 1, constant: 8)
            self.contentView.rightBarButtonContainerView.addConstraint(trailingC)
            self.setNeedsUpdateConstraints()
        }else{
            
            let nextBtn = rightButtons.first!
            
            self.contentView.rightBarButtonContainerView.hidden = false
            button.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.rightBarButtonItemWidth += 8+self.contentView.rightBarButtonContainerView.bounds.height
            self.contentView.rightBarButtonContainerView.addSubview(button)
            self.contentView.rightBarButtonContainerView.jsq_pinSubview(button, toEdge: .Top)
            self.contentView.rightBarButtonContainerView.jsq_pinSubview(button, toEdge: .Bottom)
            
           
            
            let constraint = NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: nextBtn, attribute: .Leading, multiplier: 1, constant: -8)
            let oneoneconstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Height, multiplier: 1, constant: 0)
            button.addConstraint(oneoneconstraint)
            self.contentView.rightBarButtonContainerView.addConstraint(constraint)
            self.setNeedsUpdateConstraints()
            self.delegate = self
            
        }
        
        button.associatedView.frame = CGRectZero
        
        button.associatedView.translatesAutoresizingMaskIntoConstraints = false
        self.superview!.addSubview(button.associatedView)
        let heightConstraint = NSLayoutConstraint(item: button.associatedView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: assViewHeight)
        button.associatedView.addConstraint(heightConstraint)
        let constraint = NSLayoutConstraint(item: button.associatedView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 1.0)
        let topbtmConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: button.associatedView, attribute: .Top, multiplier: 1, constant: 0)
        let centerConstraint = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: button.associatedView, attribute: .CenterX, multiplier: 1, constant: 0)
        self.superview!.addConstraints([constraint,topbtmConstraint,centerConstraint])
        
        button.associatedView.hidden = true
        
        rightButtons.insert(button, atIndex: 0)
    }
    
    var keyboardisUp:Bool = false
    var barisUp:Bool = false
    
    //postive upwards
    var displacement:CGFloat = 0
    
    func moveBarDown(){
        if displacement > 0 {
            for btn in rightButtons{
                btn.selected = false
            }
            
            barisUp = false
            moveBarToHeight(self.frame.maxY+displacement, fromKeyboard: false){
                for button in self.rightButtons{
                    button.associatedView.hidden = true
                }
            }
        }
    }
    
    let keyboardIcon = UIImage(named: "chatkeyboard.png")!
    let keyboardIcon_h = UIImage(named: "chatkeyboard-h.png")!
    
    func moveBarUp(sender:CustomToolBarButton){
        let leftBarButton = self.contentView.leftBarButtonItem
        if let leftBarButton = leftBarButton{
            if leftBarButton.selected{
                self.contentView.textView.text = tempTextViewText
                leftBarButton.selected = false
                recordButton.hidden = true
            }
        }
        if !barisUp{
            barisUp = true
            self.endEditing(true)
            let height = self.frame.maxY-(assViewHeight-displacement)
            sender.associatedView.hidden = false
            self.superview!.bringSubviewToFront(sender.associatedView)
            moveBarToHeight(height, fromKeyboard: false){}
            sender.selected = !sender.selected
        }else{
            sender.associatedView.hidden = false
            self.superview!.bringSubviewToFront(sender.associatedView)
            if sender.selected{ //should start keyboard
                self.contentView.textView.becomeFirstResponder()
            }else{
                for btn in rightButtons{
                    btn.selected = false
                }
                sender.selected = !sender.selected
            }
        }
        
    }
    
    var tempTextViewText:String = ""
    
    func messagesInputToolbar(toolbar: JSQMessagesInputToolbar!, didPressLeftBarButton sender: UIButton!) {
        if sender.selected{
            recordButton.hidden = true
            self.contentView.textView.text = tempTextViewText
            self.contentView.textView.becomeFirstResponder()
        }else{
            tempTextViewText = self.contentView.textView.text
            self.contentView.textView.text = ""
            recordButton.hidden = false
            if keyboardisUp {
                self.contentView.textView.resignFirstResponder()
            }
            if barisUp{
                moveBarDown()
            }
        }
        sender.selected = !sender.selected
    }
    
    func messagesInputToolbar(toolbar: JSQMessagesInputToolbar!, didPressRightBarButton sender: UIButton!) {
        //do nothing
    }
    
    //height is in normal frame coordinate
    func moveBarToHeight(height:CGFloat,duration:Double = 0.25, option:UIViewAnimationOptions = .CurveEaseOut, fromKeyboard:Bool ,completion:()->Void){
        let y = self.frame.maxY
        let heightFromBtm = chatVC.view.frame.height-height
        UIView.animateWithDuration(duration, delay: 0, options: option, animations: {
            self.chatVC.jsq_setToolbarBottomLayoutGuideConstant(heightFromBtm)
            self.setNeedsUpdateConstraints()
            self.layoutIfNeeded()
            }, completion: {
                success in
                completion()
        })
        displacement += y-height
        if !fromKeyboard{
            self.customDelegate.toolBarDidMoveUp(y-height)
        }

    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var frame = self.bounds
        frame.size.height += assViewHeight
        return frame.contains(point)
    }
    
    func currentAssView()->UIView?{
        if barisUp{
            for btn in rightButtons{
                if btn.selected{
                    return btn.associatedView
                }
            }
        }
        return nil
    }

    

}

class CustomToolBarButton :UIButton{
    var associatedView:UIView!
    
}