//
//  ChatViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import JSQMessagesViewController
import UIKit

class ChatViewController: JSQMessagesViewController {
    
    var conversation:EMConversation!
    
    var targetuserid:Int!
    var targetEMUsername:String!
    var targetNickname:String!
    var targetAvatarURL:String!
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var myEMUsername = EMClient.sharedClient().currentUsername

    var firstMessageID:String!
    
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    var senderImageUrl: String!
    
    let maximumLoadCount = 5
    
    convenience init(userid:Int,username:String,nickname:String,avatar:String){
        self.init()
        self.targetuserid = userid
        self.targetAvatarURL = avatar
        self.targetNickname = nickname
        self.targetEMUsername = username.lowercaseString
        self.conversation = EMClient.sharedClient().chatManager.getConversation(targetEMUsername, type: EMConversationTypeChat, createIfNotExist: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        self.title = targetNickname
        
        let avatar = UserLoginHandler.instance.avatarImageURL
        let fileURL = RetrieveImageFromS3.localDirectoryOf(avatar)
        RetrieveImageFromS3.instance.retrieveImage(avatar, bucket: S3ImagesBucketName){
            bool in
            if bool{
                self.setupAvatarImage(self.myEMUsername, imageUrl: fileURL.path!, incoming: false)
                self.senderImageUrl = fileURL.path!
            }else{//TODO: download image fail
                
            }
        }
        
        refreshControl.addTarget(self, action: #selector(loadMoreMessageFromDatabase), forControlEvents: .ValueChanged)
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
        
        self.keyboardController.textView.returnKeyType = .Send
        self.keyboardController.textView.placeholder = nil
        
        self.collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        self.senderId = myEMUsername
        self.senderDisplayName = UserLoginHandler.instance.nickname
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard)))
        
        loadMoreMessageFromDatabase()
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveMessages), name: "ReceiveNewMessageNotification", object: nil)
        
        //collectionView!.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func loadMoreMessageFromDatabase(){
        if moremessage{
            let result = conversation.loadMoreMessagesFromId(firstMessageID, limit: Int32(maximumLoadCount))
            conversation.markAllMessagesAsRead()
            if result.count > 0 {
                firstMessageID = (result[0] as! EMMessage).messageId
                var tempMsg:[JSQMessage] = []
                var indexPaths:[NSIndexPath] = []
                var i = 0
                for message in result{
                    indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
                    let m = message as! EMMessage
                    let jsq = convertMessage(m)
                    tempMsg.append(jsq)
                    i+=1
                }
                
                if tempMsg.count == maximumLoadCount{
                    self.moremessage = true
                }else{
                    self.moremessage = false
                }
                
                tempMsg.appendContentsOf(messages)
                messages = tempMsg
                
                if messages.count <= maximumLoadCount {
                    self.collectionView?.reloadData()
                }else{
                    self.collectionView?.insertItemsAtIndexPaths(indexPaths)
                    self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: i,inSection: 0), atScrollPosition: .Top, animated: false)
                }
                
                refreshControl.endRefreshing()
                
//                if messages.count <= maximumLoadCount {
//                    self.collectionView?.reloadData()
//                    refreshControl.endRefreshing()
//                }else{
//                
//                    let contentHeight = self.collectionView!.contentSize.height
//                    let offsetY = self.collectionView!.contentOffset.y
//                    let bottomOffset = contentHeight - offsetY
//                    
//                    CATransaction.begin()
//                    CATransaction.setDisableActions(true)
//                    
//                    self.collectionView!.performBatchUpdates({
//                        if indexPaths.count > 0 {
//                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
//                        }
//                        }, completion: {
//                            finished in
//                            print("completed loading of new stuff, animating\(self.collectionView!.contentSize.height)")
//                            self.collectionView!.contentOffset = CGPointMake(0, self.collectionView!.contentSize.height - bottomOffset)
//                            CATransaction.commit()
//                    })
//                }
            }else{
                refreshControl.endRefreshing()
            }
        }else{
            refreshControl.endRefreshing()
        }
    }
    
    var moremessage = true
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"{
            if textView.text != "" {
                self.didPressSendButton(nil, withMessageText:self.keyboardController.textView?.text , senderId:self.senderId , senderDisplayName: self.senderDisplayName, date: NSDate())
                textView.text = ""
            }
            return false
        }
        
        return true
    }
    

    
    func convertMessage(message:EMMessage)->JSQMessage{
        switch message.body.type{
        case EMMessageBodyTypeText:
            let body = message.body as! EMTextMessageBody
            let displayname = (message.from == myEMUsername ? UserLoginHandler.instance.nickname : targetNickname)
            let jsq = JSQMessage(senderId: message.from, displayName: displayname, text: body.text)
            return jsq
        default:
            break
        }
        return JSQMessage()
    }
    
    
    func didReceiveMessages(notification:NSNotification) {
        let json = notification.userInfo!
        let conversationid = json["id"] as! [String]
        if conversationid.contains(targetEMUsername){
            let count = conversation.unreadMessagesCount
            let aMessages = conversation.loadMoreMessagesFromId(nil, limit: count)
            conversation.markAllMessagesAsRead()
            for m in aMessages{
                let message:EMMessage = m as! EMMessage
                let jsq = convertMessage(message)
                messages.append(jsq)
            }
            self.finishReceivingMessageAnimated(true)
        }else{ //other conversation received message
            
        }
        
    }
    
    func sendMessage(text: String!) {
        let body = EMTextMessageBody(text: text)
        let from = EMClient.sharedClient().currentUsername
        let message = EMMessage(conversationID: targetEMUsername, from: from, to: targetEMUsername, body: body, ext: nil)
        message.chatType = EMChatTypeChat
        
        EMClient.sharedClient().chatManager.asyncSendMessage(message, progress: nil){
            message,error in
            if error == nil{ //finish sending message
                self.messages.append(self.convertMessage(message))
                self.finishSendingMessageAnimated(true)
            }
        }
    }
    
    func tempSendMessage(text: String!) {
        let message = JSQMessage(senderId: myEMUsername, displayName: UserLoginHandler.instance.nickname, text: text)
        messages.append(message)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage =  JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(name.startIndex.advancedBy(min(3, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(13), diameter: diameter)
        
        avatars[name] = userImage
    }
    

    
    // ACTIONS
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text)
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == myEMUsername {
            return outgoingBubbleImage
        }
        
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.senderId] {
            return avatar
        } else {
            setupAvatarImage(message.senderId, imageUrl: targetAvatarURL, incoming: true)
            return avatars[message.senderId]
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.senderId == myEMUsername {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView!.textColor!, NSUnderlineStyleAttributeName: 1]
        cell.textView!.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        var userid:Int!
        if messages[indexPath.row].senderId == myEMUsername{
            userid = UserLoginHandler.instance.userid
        }else{
            userid = targetuserid
        }
        let vc = UserOverviewController(userid: userid, nextURL: userPostedURL)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

