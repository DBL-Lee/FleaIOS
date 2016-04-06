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
import KDCircularProgress


class RetrieveImageFromS3{
    static let instance = RetrieveImageFromS3()
    
    //map from currently downloading processes to all completion handlers
    var downloadObserver:[String:([Bool->Void],[Int->Void])] = [:]
    
    func retrieveImage(imageUUID:String,bucket:String,percentageHandler:Int->Void = {_ in},completion:Bool->Void){
        let url = LocalDownloadDirectory.URLByAppendingPathComponent(imageUUID)
        if NSFileManager.defaultManager().fileExistsAtPath(url.path!){ //already cached in download directory
            dispatch_async(dispatch_get_main_queue(), {
                completion(true)
            })
            return
        }
        
        //update observers if already downloading
        if var (completionHandlers,percentageHandlers) = downloadObserver[bucket+imageUUID]{
            completionHandlers.append(completion)
            percentageHandlers.append(percentageHandler)
            downloadObserver[bucket+imageUUID] =  (completionHandlers,percentageHandlers)
            return
        }
        
        downloadObserver[bucket+imageUUID] = ([],[])
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket = bucket
        downloadRequest.key = imageUUID
        downloadRequest.downloadingFileURL = url
        downloadRequest.downloadProgress = {
            (bytesDownload,totalBytesDownloaded,totalBytesExpected) in
            dispatch_async(dispatch_get_main_queue(), {
                if totalBytesExpected>0{
                    let percentage = Int(100*Double(totalBytesDownloaded)/Double(totalBytesExpected))
                        percentageHandler(percentage)
                    for handler in self.downloadObserver[bucket+imageUUID]!.1{
                        handler(percentage)
                    }
                }
            })
        }
        AWSS3TransferManager.defaultS3TransferManager().download(downloadRequest).continueWithBlock{
            task->AnyObject? in
            if let error = task.error{
                print(error)
                completion(false)
                for handler in self.downloadObserver[bucket+imageUUID]!.0{
                    handler(false)
                }
                self.downloadObserver[bucket+imageUUID] = nil
            }else if let ex = task.exception{
                print(ex)
                completion(false)
                for handler in self.downloadObserver[bucket+imageUUID]!.0{
                    handler(false)
                }
                self.downloadObserver[bucket+imageUUID] = nil
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    completion(true)
                    for handler in self.downloadObserver[bucket+imageUUID]!.0{
                        handler(true)
                    }
                    self.downloadObserver[bucket+imageUUID] = nil
                })
            }
            
            return nil
        }
    }
    
    static func retrieveCategoryIcon(icon:String,completion:()->Void){
        let url = LocalIconDirectory.URLByAppendingPathComponent(icon)
        if NSFileManager.defaultManager().fileExistsAtPath(url.path!){
            dispatch_async(dispatch_get_main_queue(), {
                completion()
            })
            return
        }
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket = S3IconBucketName
        downloadRequest.key = icon
        downloadRequest.downloadingFileURL = url
        
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