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

class ChatListTableViewController: UITableViewController,AGEmojiKeyboardViewDataSource,AGEmojiKeyboardViewDelegate {

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
        
        let emojiView = AGEmojiKeyboardView(frame: CGRect(x: 50, y: 100, width: 300, height: 300), dataSource: self)
        emojiView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        emojiView.delegate = self
        //abutton.associatedView = emojiView
        //self.view.addSubview(emojiView)
        //_inputToolbar.addButtonToRightBar(abutton)
        //        emojiView.emojiPagesScrollView.canCancelContentTouches = true
        //        emojiView.emojiPagesScrollView.delaysContentTouches = false
        self.view.addSubview(emojiView)
    }
    
    //MARK: EMOJI DELEGATE
    func emojiKeyBoardView(emojiKeyBoardView: AGEmojiKeyboardView!, didUseEmoji emoji: String!) {
        //self._inputToolbar.contentView.textView.text = self._inputToolbar.contentView.textView.text + emoji
    }
    
    func emojiKeyBoardViewDidPressBackSpace(emojiKeyBoardView: AGEmojiKeyboardView!) {
       // self._inputToolbar.contentView.textView.deleteBackward()
    }
    
    //MARK: EMOJI DATASOURCE
    func emojiKeyboardView(emojiKeyboardView: AGEmojiKeyboardView!, imageForSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage! {
        return UIColor.greenColor().toImage()
    }
    
    func emojiKeyboardView(emojiKeyboardView: AGEmojiKeyboardView!, imageForNonSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage! {
        return UIColor.redColor().toImage()
    }
    
    func backSpaceButtonImageForEmojiKeyboardView(emojiKeyboardView: AGEmojiKeyboardView!) -> UIImage! {
        return UIColor.blackColor().toImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveMessages), name: "ReceiveNewMessageNotification", object: nil)
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.labelText = "加载中"
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
                chatManager.deleteConversation(con.conversationId, deleteMessages: true)
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
