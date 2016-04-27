//
//  AvatarFactory.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class AvatarFactory{
    static func setupImageView(bucket:String,imageView:UIImageView, image:String, square:Bool = false){
        let fileURL = RetrieveImageFromS3.localDirectoryOf(image)
        if image == "default"{
            let squareIm = UIImage(named:"defaultavatar.png")
            imageView.image = square ? squareIm : JSQMessagesAvatarImageFactory.avatarImageWithImage(squareIm, diameter: UInt(imageView.frame.width)).avatarImage
        }else if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){
            let squareIm = UIImage(contentsOfFile: fileURL.path!)!
            imageView.image = square ? squareIm : JSQMessagesAvatarImageFactory.avatarImageWithImage(squareIm, diameter: UInt(imageView.frame.width)).avatarImage
        }else{
            let tag = imageView.tag
            RetrieveImageFromS3.instance.retrieveImage(image, bucket: bucket){
                bool in
                if bool {
                    if imageView.tag == tag {
                        let squareIm = UIImage(contentsOfFile: fileURL.path!)!
                        imageView.image = square ? squareIm :JSQMessagesAvatarImageFactory.avatarImageWithImage(squareIm, diameter: UInt(imageView.frame.width)).avatarImage
                    }
                }else{ //TODO: download image fail
                    
                }
            }
        }
    }
    static func setupAvatarImageView(imageView:UIImageView, avatar:String, square:Bool = false){
        AvatarFactory.setupImageView(S3AvatarsBucketName, imageView: imageView, image: avatar, square: square)
    }
    
    static func setupNormalImageView(imageView:UIImageView, image:String){
        AvatarFactory.setupImageView(S3ImagesBucketName, imageView: imageView, image: image, square: true)
    }
}
