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
    
    static func reloadAvatar(nickname:String,completion:Bool->Void){
        let fileURL = RetrieveImageFromS3.localDirectoryOf(nickname+".png")
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){ //already cached in download directory
            do{
                try NSFileManager.defaultManager().removeItemAtURL(fileURL)
            }catch{
                
            }
        }
        RetrieveImageFromS3.instance.retrieveImage(nickname+".png", bucket: S3AvatarsBucketName, completion: completion)
    }
    
    static func setupImageView(bucket:String,imageView:UIImageView, image:String, square:Bool = false,percentageHandler:Int->(), completion:()->Void){
        let fileURL = RetrieveImageFromS3.localDirectoryOf(image)
        if image == "default"{
            let squareIm = UIImage(named:"defaultavatar.png")
            imageView.image = square ? squareIm : JSQMessagesAvatarImageFactory.avatarImageWithImage(squareIm, diameter: UInt(imageView.frame.width)).avatarImage
            percentageHandler(100)
            completion()
        }else if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){
            let squareIm = UIImage(contentsOfFile: fileURL.path!)!
            imageView.image = square ? squareIm : JSQMessagesAvatarImageFactory.avatarImageWithImage(squareIm, diameter: UInt(imageView.frame.width)).avatarImage
            percentageHandler(100)
            completion()
        }else{
            let tag = imageView.tag
            RetrieveImageFromS3.instance.retrieveImage(image, bucket: bucket,percentageHandler: percentageHandler){
                bool in
                if bool {
                    if imageView.tag == tag {
                        let squareIm = UIImage(contentsOfFile: fileURL.path!)!
                        imageView.image = square ? squareIm :JSQMessagesAvatarImageFactory.avatarImageWithImage(squareIm, diameter: UInt(imageView.frame.width)).avatarImage
                        completion()
                    }
                }else{ //TODO: download image fail
                    
                }
            }
        }
    }
    static func setupAvatarImageView(imageView:UIImageView, avatar:String, square:Bool = false,percentageHandler:Int->() = {_ in }, completion:()->Void = {}){
        AvatarFactory.setupImageView(S3AvatarsBucketName, imageView: imageView, image: avatar, square: square,percentageHandler: percentageHandler, completion: completion)
    }
    
    static func setupNormalImageView(imageView:UIImageView, image:String,percentageHandler:Int->() = {_ in }, completion:()->Void = {}){
        AvatarFactory.setupImageView(S3ImagesBucketName, imageView: imageView, image: image, square: true,percentageHandler: percentageHandler, completion: completion)
    }
}
