//
//  PostImageTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 26/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PostImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    var row = 1
    let column = 4
    var side:CGFloat!
    let margin:CGFloat = 5
    let offset:CGFloat = 10
    var width:CGFloat!
    var deleteCallBack:Int->Bool = {_ in return true}
    var additionCallBack:()->Void = {}
    var mainIm = 0
    var tapHandler:Int->Void = {_ in}
    
    var imageViews:[ImageWithDeletionView] = []
    var addPhotoView:UIButton = UIButton(type: UIButtonType.Custom)
    
    
    
    func addPhotos(images:[UIImage]){
        let count = images.count+imageViews.count
        
        if count<GLOBAL_MAXIMUMPHOTO {
            //show add photo button
            row = count/column+1
        }else{
            //does not show add photo button
            row = (count-1)/column+1
        }
        
        //adjust height for container view
        self.heightConstraint.constant = side*CGFloat(row)+offset*2
        
        var i = imageViews.count/column
        var j = imageViews.count%column
        for image in images{
            let origin = CGPoint(x: offset+CGFloat(j)*side+margin*CGFloat(j-1), y: offset+CGFloat(i)*side+CGFloat(i-1)*margin)
            let size = CGSize(width: side, height: side)
            let frame = CGRect(origin: origin, size: size)
            let view = ImageWithDeletionView(frame: frame, image: image,callback: removeImageAtIndex,index:i*column+j,mainIm: mainIm==i*column+j,overlay: true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(PostImageTableViewCell.handleTap(_:)))
            view.addGestureRecognizer(tap)
            self.containerView.addSubview(view)
            imageViews.append(view)
            j += 1
            if j==column{
                j=0
                i += 1
            }
        }
        
        let origin = CGPoint(x: offset+CGFloat(j)*side+offset, y: offset+CGFloat(i)*side+offset)
        let size = CGSize(width: side-offset, height: side-offset)
        let frame = CGRect(origin: origin, size: size)
        
        self.addPhotoView.frame = frame
        if count==GLOBAL_MAXIMUMPHOTO {
            //does not show add photo button
            self.addPhotoView.hidden = true
        }
    }
    
    func setImages(images:[UIImage],deleteCallBack:Int->Bool,additionCallBack:()->Void,tapHandler:Int->Void){
        self.deleteCallBack = deleteCallBack
        self.additionCallBack = additionCallBack
        self.tapHandler = tapHandler
        
        //2*8 for distance btw container view and boundary
        //offset*2 for left and right offset inside container view
        //margin for margin between every image
        side = (width-CGFloat(8*2)-offset*2-margin*CGFloat(column-1))/CGFloat(column)
        
        
        let count = images.count
        if count<GLOBAL_MAXIMUMPHOTO {
            //show add photo button
            row = count/column+1
        }else{
            //does not show add photo button
            row = (count-1)/column+1
        }
        
        //adjust height for container view
        self.heightConstraint.constant = side*CGFloat(row)+offset*2
        
        self.addPhotoView.frame = CGRect(x: offset, y: offset, width: side, height: side)
        self.addPhotoView.setBackgroundImage(UIImage(named: "addPhoto.png"), forState: .Normal)
        self.addPhotoView.addTarget(self, action: #selector(PostImageTableViewCell.addBtnPressed), forControlEvents: .TouchUpInside)
        self.containerView.addSubview(self.addPhotoView)
        
        addPhotos(images)
        
    }
    
    func uploadPercentageChanged(imageIndex:Int,percentage:Int){
        imageViews[imageIndex].setPercentage(percentage)
    }
    
    func addBtnPressed(){
        additionCallBack()
    }
    
    func changeMainIm(newIm:Int){
        imageViews[mainIm].removeMainIm()
        imageViews[newIm].setMainIm()
        mainIm = newIm
    }
    
    func handleTap(tap:UITapGestureRecognizer){
        let view = tap.view! as! ImageWithDeletionView
        tapHandler(view.index)
    }
    
    func removeImageAtIndex(i:Int){
        
        if deleteCallBack(i){
        
            if i<mainIm{
                mainIm -= 1
            }
            
            let removedView = imageViews.removeAtIndex(i)
            var frame = removedView.frame
            for j in i..<imageViews.count{
                let tempFrame = imageViews[j].frame
                imageViews[j].index = j
                imageViews[j].frame = frame
                frame = tempFrame
            }
            self.addPhotoView.frame = frame
            removedView.removeFromSuperview()
            let count = imageViews.count
            row = count/column+1
            self.heightConstraint.constant = side*CGFloat(row)+offset*2
            
            /*
            As long as not the only image is deleted,
            it sets the current mainIm as main image
            */
            if !imageViews.isEmpty{
                imageViews[mainIm].setMainIm()
            }
            self.addPhotoView.hidden = false
            
        }
        
        
    }
    
    
    
}
