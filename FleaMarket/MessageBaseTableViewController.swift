//
//  MessageBaseTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/06/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class MessageBaseTableViewController: UITableViewController {
    var userMessageCell:MessageBaseTableViewCell!
    var orderMessageCell:MessageBaseTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "消息"
        
        tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top+20, tableView.contentInset.left, tableView.contentInset.bottom, tableView.contentInset.right)
        
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        tableView.registerNib(UINib(nibName: "MessageBaseTableViewCell",bundle: nil), forCellReuseIdentifier: "MessageBaseTableViewCell")
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        userMessageCell = self.tableView.dequeueReusableCellWithIdentifier("MessageBaseTableViewCell", forIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! MessageBaseTableViewCell
        userMessageCell.setupCell("私信", image: UIImage(named: "userMessage.png")!)
        
        orderMessageCell = self.tableView.dequeueReusableCellWithIdentifier("MessageBaseTableViewCell", forIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as! MessageBaseTableViewCell
        orderMessageCell.setupCell("订单消息", image: UIImage(named: "orderMessage.png")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let message = NSUserDefaults.standardUserDefaults().objectForKey("LastUserMessage") as? String
        if let message = message{
            userMessageCell.updateMessage(message, count: unreadUserMessageCount())
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveMessages), name: ReceiveNewMessageNotificationName, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didReceiveMessages(notification:NSNotification){
        let userinfo = notification.userInfo!
        let lastMsg = userinfo["lastMsg"] as! String
        userMessageCell.updateMessage(lastMsg,count: unreadUserMessageCount())
    }
    
    func unreadUserMessageCount()->Int{
        let conversations = EMClient.sharedClient().chatManager.getAllConversations()
        var totalUnread = 0
        for c in conversations{
            totalUnread += Int(c.unreadMessagesCount)
        }
        return totalUnread
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            return userMessageCell
        case 1:
            return orderMessageCell
        default:
            break
        }
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row{
        case 0:
            let vc = ChatListTableViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            break
        default:
            break
        }
    }
   
}
