//
//  EaseDataHandler.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 29/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

class EaseDataHandler:NSObject,EMChatManagerDelegate{
    static var shared = EaseDataHandler()
    
    func didReceiveMessages(aMessages: [AnyObject]!) {
        
        //let notification = NSNotification(name: <#T##String#>, object: <#T##AnyObject?#>, userInfo: <#T##[NSObject : AnyObject]?#>)
        var idset:[String] = []
        for m in aMessages{
            let message = m as! EMMessage
            if !idset.contains(message.conversationId){
                idset.append(message.conversationId)
            }
            if UIApplication.sharedApplication().applicationState == .Background{ //push notification if in background
                let notification = UILocalNotification()
                let ext = message.ext
                let title = ext["em_apns_ext"]!["em_push_title"]! as! NSArray
                notification.alertBody = title[0] as? String
                notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber+1
                notification.fireDate = NSDate()
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
        var userInfo:[NSObject:AnyObject] = [:]
        userInfo["id"] = idset
        userInfo["count"] = aMessages.count
        NSNotificationCenter.defaultCenter().postNotificationName("ReceiveNewMessageNotification", object: nil,userInfo: userInfo)
    }
    
}