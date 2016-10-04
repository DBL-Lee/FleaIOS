//
//  CustomJSQPhotoMediaItem.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 26/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MBProgressHUD
class CustomJSQPhotoMediaItem: JSQPhotoMediaItem {
    

    var overlay:MBProgressHUD = MBProgressHUD(frame: CGRectZero)
    
    func updateProgress(progress:Float){
        if progress == 1.0{
            overlay.hideAnimated(true)
        }
        if progress == 0.0{
            overlay.showAnimated(true)
        }
        overlay.progress = progress
    }
    
    override func mediaView() -> UIView! {
        let view = super.mediaView()
        

        overlay.mode = .AnnularDeterminate
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.progress = 0
        view.addSubview(overlay)
        view.jsq_pinAllEdgesOfSubview(overlay)

        
        return view
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        if image == nil {
            return super.mediaViewDisplaySize()
        }
        let max:CGFloat = 150.0
        let width = image.size.width
        let height = image.size.height
        if width < height{
            return CGSize(width: max * width / height, height: max)
        }else{
            return CGSize(width: max, height: max * height / width)
        }
        
    }
}
