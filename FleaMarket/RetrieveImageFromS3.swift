//
//  RetrieveImageFromS3.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore

class RetrieveImageFromS3{
    static func retrieveImage(imageUUID:String,percentageHandler:Int->Void = {_ in},completion:()->Void){
        let url = LocalDownloadDirectory.URLByAppendingPathComponent(imageUUID)
        if NSFileManager.defaultManager().fileExistsAtPath(url.path!){
            dispatch_async(dispatch_get_main_queue(), {
                completion()
            })
            return
        }
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket = S3BucketName
        downloadRequest.key = imageUUID
        downloadRequest.downloadingFileURL = url
        downloadRequest.downloadProgress = {
            (bytesDownload,totalBytesDownloaded,totalBytesExpected) in
            dispatch_async(dispatch_get_main_queue(), {
                if totalBytesExpected>0{
                    let percentage = Int(100*Double(totalBytesDownloaded)/Double(totalBytesExpected))
                    
                    percentageHandler(percentage)
                }
            })
        }
        AWSS3TransferManager.defaultS3TransferManager().download(downloadRequest).continueWithBlock{
            task->AnyObject? in
            if let error = task.error{
                print(error)
            }else if let ex = task.exception{
                print(ex)
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    completion()
                })
            }
            
            return nil
        }
    }
    
    static func localDirectoryOf(imageUUID:String)->NSURL{
        let fileURL = LocalDownloadDirectory.URLByAppendingPathComponent(imageUUID)
        return fileURL
    }
}