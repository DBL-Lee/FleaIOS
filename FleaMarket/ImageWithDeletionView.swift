//
//  ImageWithDeletionView.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 26/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import KDCircularProgress

class ImageWithDeletionView: UIView,UIGestureRecognizerDelegate {
    var index:Int
    let callback:Int->Void
    let buttonSide:CGFloat = 20
    let mainImHeight:CGFloat = 20
    let label:UILabel!
    let button = UIButton(type: .Custom)
    var uploadOverlay:UIView!
    var roundIndicator:KDCircularProgress!
    
    init(frame: CGRect,image:UIImage,callback:Int->Void,index:Int,mainIm:Bool = false, overlay:Bool = false) {
        self.index = index
        self.callback = callback
        
        let height = frame.height
        let width = frame.width

        label = UILabel(frame: CGRect(x: CGFloat(buttonSide/2), y: height-mainImHeight, width: width-CGFloat(buttonSide/2), height: mainImHeight))
        label.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.5)
        label.text = "主图"
        label.font = UIFont.systemFontOfSize(8)
        label.textColor = UIColor.whiteColor()
        label.adjustsFontSizeToFitWidth = true
        label.hidden = true
        label.textAlignment = .Center
        
        super.init(frame: frame)
        let imageView = UIImageView(frame: CGRect(x: buttonSide/2, y: buttonSide/2, width: width-buttonSide/2, height: height-buttonSide/2))
        button.frame = CGRect(x: 0, y: 0, width: buttonSide, height: buttonSide)
        button.setBackgroundImage(UIImage(named: "delete.png"), forState: .Normal)
        button.addTarget(self, action: #selector(ImageWithDeletionView.delete as (ImageWithDeletionView) -> () -> ()), forControlEvents: .TouchUpInside)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = image
        imageView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        button.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(imageView)
        
        if overlay{
            uploadOverlay = UIView(frame: CGRect(x: 0, y: 0, width: width-buttonSide/2, height: height-buttonSide/2))
            uploadOverlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            roundIndicator = KDCircularProgress()
            roundIndicator.startAngle = -90
            roundIndicator.frame = CGRect(x: 0, y: 0, width: (width-buttonSide/2)/2, height: (height-buttonSide/2)/2)
            uploadOverlay.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
            roundIndicator.autoresizingMask = [.FlexibleTopMargin,.FlexibleBottomMargin,.FlexibleLeftMargin,.FlexibleRightMargin]
            roundIndicator.setColors(UIColor.whiteColor())
            uploadOverlay.addSubview(roundIndicator)
            roundIndicator.center = uploadOverlay.center
            imageView.addSubview(uploadOverlay)
        }
        self.addSubview(button)
        self.addSubview(label)
        
        if mainIm{
            label.hidden = false
        }
        
    }

    func removeMainIm(){
        self.label.hidden = true
    }
    
    func setMainIm(){
        self.label.hidden = false
    }
    
    func delete(){
        callback(index)
    }
    
    func setPercentage(percentage:Int){
        roundIndicator.angle = percentage*360/100
        if percentage == 100 {
            uploadOverlay.removeFromSuperview()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == button{
            return false
        }
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
