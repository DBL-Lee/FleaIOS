//
//  ChatListTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 29/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MBProgressHUD
//import AGEmojiKeyboard

class ChatListTableViewController: UITableViewController {

    var chatManager:IEMChatManager!
    var conversations:[EMConversation] = []
    var conversationUserMap:[EMConversation:User] = [:]
    
    var totalUnreadCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatManager = EMClient.sharedClient().chatManager
        
        self.tableView.registerNib(UINib(nibName: "ConversationTableViewCell",bundle: nil), forCellReuseIdentifier: "ConversationTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 76
        self.tableView.tableFooterView = UIView()
        
        self.title = "消息"
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveMessages), name: ReceiveNewMessageNotificationName, object: nil)
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.label.text = "加载中"
        reloadConversations()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didReceiveMessages(notification:NSNotification) {
        reloadConversations()
    }
    
    func reloadConversations(){
        let result = chatManager.getAllConversations()
        conversations = []
        totalUnreadCount = 0
        for r in result{
            let con = r as! EMConversation
            if con.latestMessage != nil{
                conversations.append(con)
                totalUnreadCount += Int(con.unreadMessagesCount)
            }else{ //delete empty conversations
                chatManager.deleteConversation(con.conversationId, isDeleteMessages: true, completion: nil)
            }
        }
        
        if totalUnreadCount == 0{
            self.navigationController!.tabBarItem.badgeValue = nil
        }else{
            self.navigationController!.tabBarItem.badgeValue = "\(totalUnreadCount)"
        }
        
        if conversations.count == 0 {
            MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
            return
        }
        
        //sort conversations
        self.conversations.sortInPlace{
            c1,c2 in
            return c1.latestMessage.timestamp>c2.latestMessage.timestamp
        }
        
        var count = conversations.count
        for conversation in conversations{
            count -= 1
            CoreDataHandler.instance.getUserFromCoreData(nil, emusername: conversation.conversationId){
                user in
                if let user = user{
                    self.conversationUserMap[conversation] = user
                    if count == 0 {
                        self.tableView.reloadData()
                         MBProgressHUD.hideAllHUDsForView(self.navigationController!.view, animated: true)
                        
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ConversationTableViewCell = tableView.dequeueReusableCellWithIdentifier("ConversationTableViewCell", forIndexPath: indexPath) as! ConversationTableViewCell
        let user = conversationUserMap[conversations[indexPath.row]]
        if let user = user {
            cell.setupCell(user, conversation: conversations[indexPath.row])
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let conversation = conversations[indexPath.row]
        let user = conversationUserMap[conversation]
        if let user = user{
            let vc = ChatViewController(userid: user.id,username: user.emusername, nickname: user.nickname, avatar: user.avatar)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
