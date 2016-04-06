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
        }
        var userInfo:[NSObject:AnyObject] = [:]
        userInfo["id"] = idset
        NSNotificationCenter.defaultCenter().postNotificationName("ReceiveNewMessageNotification", object: nil,userInfo: userInfo)
    }
    
}