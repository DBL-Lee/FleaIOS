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
        
        var idset:[String] = []
        for m in aMessages{
            let message = m as! EMMessage
            if !idset.contains(message.conversationId){
                idset.append(message.conversationId)
            }
            if UIApplication.sharedApplication().applicationState == .Background{ //push notification if in background
                let notification = UILocalNotification()
                let ext = message.ext
                print(ext["em_apns_ext"]!["em_push_title"])
                let title = ext["em_apns_ext"]!["em_push_title"]! as! String
                notification.alertBody = title
                notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber+1
                notification.fireDate = NSDate()
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
        var userInfo:[NSObject:AnyObject] = [:]
        userInfo["id"] = idset
        userInfo["count"] = aMessages.count
        let lastMsg = aMessages.last as! EMMessage
        print(lastMsg.ext["em_apns_ext"])
        print(lastMsg.ext["em_apns_ext"]!["em_push_title"])
        let title = lastMsg.ext["em_apns_ext"]!["em_push_title"]! as! String
        userInfo["lastMsg"] = title
        NSUserDefaults.standardUserDefaults().setValue(title, forKey: "LastUserMessage")
        NSNotificationCenter.defaultCenter().postNotificationName(ReceiveNewMessageNotificationName, object: nil,userInfo: userInfo)
    }
    
}