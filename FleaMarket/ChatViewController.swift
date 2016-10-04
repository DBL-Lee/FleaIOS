//
//  ChatViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import JSQMessagesViewController
import UIKit
import MBProgressHUD
import Alamofire
import SwiftyJSON
//import AGEmojiKeyboard

class CustomChatLayout : JSQMessagesCollectionViewFlowLayout {
    
}

enum MessageStatus{
    case Sending
    case Success
    case Failed
}

class Message : JSQMessage{
    var status:MessageStatus = .Sending
}

class ChatViewController: JSQMessagesViewController, CustomInputToolBarDelegate,UIGestureRecognizerDelegate {
    
    var conversation:EMConversation!
    
    var targetuserid:Int!
    var targetEMUsername:String!
    var targetNickname:String!
    var targetAvatarURL:String!
    var myEMUsername = EMClient.sharedClient().currentUsername
    
    var _inputToolbar : CustomInputToolBar!
    
    let refreshHeader = UIRefreshControl()

    var firstMessageID:String? = nil
    
    var rawmessages:[EMMessage] = []
    var messages:[Message] = []
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    var senderImageUrl: String!
    var product:Product?
    
    let maximumLoadCount = 30
    
    
    override class func nib()->UINib{
        return UINib(nibName: "JSQMessagesViewController", bundle: nil)
    }
    
    convenience init(userid:Int,username:String,nickname:String,avatar:String,product:Product? = nil){
        self.init()
        self.targetuserid = userid
        self.targetAvatarURL = avatar
        self.targetNickname = nickname
        self.targetEMUsername = username.lowercaseString
        self.conversation = EMClient.sharedClient().chatManager.getConversation(targetEMUsername, type: EMConversationTypeChat, createIfNotExist: true)
        
        self.product = product
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.incomingCellIdentifier = CustomMessageCellIncoming.cellReuseIdentifier()
//        self.incomingMediaCellIdentifier = CustomMessageCellIncoming.mediaCellReuseIdentifier()
//        self.outgoingCellIdentifier = CustomMessageCellOutgoing.cellReuseIdentifier()
//        self.outgoingMediaCellIdentifier = CustomMessageCellOutgoing.mediaCellReuseIdentifier()
//        
//        self.collectionView.registerNib(CustomMessageCellIncoming.nib(), forCellWithReuseIdentifier: CustomMessageCellIncoming.cellReuseIdentifier())
//        self.collectionView.registerNib(CustomMessageCellIncoming.nib(), forCellWithReuseIdentifier: CustomMessageCellIncoming.mediaCellReuseIdentifier())
//        self.collectionView.registerNib(CustomMessageCellOutgoing.nib(), forCellWithReuseIdentifier: CustomMessageCellOutgoing.cellReuseIdentifier())
//        self.collectionView.registerNib(CustomMessageCellOutgoing.nib(), forCellWithReuseIdentifier: CustomMessageCellOutgoing.mediaCellReuseIdentifier())
        
        
        
        self.collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.collectionView.collectionViewLayout.minimumLineSpacing = 20
        
        self._inputToolbar = inputToolbar as! CustomInputToolBar
        inputToolbar.contentView.leftBarButtonItem = nil
        _inputToolbar.contentView.rightBarButtonItem = nil
        _inputToolbar.customDelegate = self
        _inputToolbar.delegate = nil
        _inputToolbar.chatVC = self
        
//        let voiceBtn = UIButton(type: .Custom)
//        voiceBtn.setTitle("", forState: .Normal)
//        voiceBtn.setBackgroundImage(UIImage(named: "chatvoice.png"), forState: .Normal)
//        voiceBtn.setBackgroundImage(UIImage(named: "chatvoice-h.png"), forState: .Highlighted)
//        voiceBtn.setBackgroundImage(UIImage(named: "chatkeyboard.png"), forState: .Selected)
//        _inputToolbar.contentView.leftBarButtonItem = voiceBtn
        
        let button = CustomToolBarButton(type: .Custom)
        button.setTitle("", forState: .Normal)
        button.setBackgroundImage(UIImage(named: "chatadd.png"), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "chatadd-h.png"), forState: .Highlighted)
        button.setBackgroundImage(UIImage(named: "chatkeyboard.png"), forState: .Selected)
        let moreView = setupMoreView()
        button.associatedView = moreView
        _inputToolbar.addButtonToRightBar(button)
        
//        let abutton = CustomToolBarButton(type: .Custom)
//        abutton.setTitle("", forState: .Normal)
//        abutton.setBackgroundImage(UIImage(named: "chatemoji.png"), forState: .Normal)
//        abutton.setBackgroundImage(UIImage(named: "chatemoji-h.png"), forState: .Highlighted)
//        abutton.setBackgroundImage(UIImage(named: "chatkeyboard.png"), forState: .Selected)
//        let emojiView = AGEmojiKeyboardView(frame: CGRect(x: 50, y: 100, width: 300, height: 300), dataSource: self)
//        emojiView.backgroundColor = UIColor.groupTableViewBackgroundColor()
//        emojiView.delegate = self
//        abutton.associatedView = emojiView
//        self.view.addSubview(emojiView)
//        _inputToolbar.addButtonToRightBar(abutton)
//        emojiView.emojiPagesScrollView.canCancelContentTouches = true
//        emojiView.emojiPagesScrollView.delaysContentTouches = false
        //self.view.addSubview(emojiView)
        
        automaticallyScrollsToMostRecentMessage = true
        
        
        
        self.title = targetNickname
        
        self.keyboardController.textView.returnKeyType = .Send
        self.keyboardController.textView.placeholder = nil
        
        self.senderId = myEMUsername
        self.senderDisplayName = UserLoginHandler.instance.nickname
        
        //load avatars
        RetrieveImageFromS3.instance.retrieveImage(targetAvatarURL, bucket: S3AvatarsBucketName, completion: {
            success in
            if success{
                let im = UIImage(contentsOfFile: RetrieveImageFromS3.localDirectoryOf(self.targetAvatarURL).path!)!
                self.avatars[self.targetEMUsername] = JSQMessagesAvatarImage(avatarImage: im, highlightedImage: im, placeholderImage: im)
                self.collectionView.reloadData()
            }else{
                
            }
        })
        let myAvatar = UserLoginHandler.instance.avatarImageURL
        RetrieveImageFromS3.instance.retrieveImage(myAvatar, bucket: S3AvatarsBucketName, completion: {
            success in
            if success{
                let im = UIImage(contentsOfFile: RetrieveImageFromS3.localDirectoryOf(myAvatar).path!)!
                self.avatars[self.myEMUsername] = JSQMessagesAvatarImage(avatarImage: im, highlightedImage: im, placeholderImage: im)
                self.collectionView.reloadData()
            }else{
                
            }
        })
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        tap.delegate = self
        self.collectionView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        pan.delegate = self
        self.collectionView.addGestureRecognizer(pan)
        
        //set size for avatar to be height of one single row
        let calculator = JSQMessagesBubblesSizeCalculator.init(cache: NSCache(), minimumBubbleWidth: 100, usesFixedWidthBubbles: false)
        let testMessage = Message(senderId: "", displayName: "", text: "test")
        let onerowSize:CGSize = calculator.messageBubbleSizeForMessageData(testMessage, atIndexPath: NSIndexPath(forItem: 0,inSection: 0), withLayout: self.collectionView.collectionViewLayout)
        let side = onerowSize.height
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: side, height: side)
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: side, height: side)
        
        self._inputToolbar.maximumHeight = 100
        
        if product != nil {
            let buyButton = UIBarButtonItem(title: "求购", style: .Plain, target: self, action: #selector(wantToBuy))
            self.navigationItem.rightBarButtonItem = buyButton
        }
        
        loadMoreMessageFromDatabase()
    }
    
    func wantToBuy(){
        let alert = UIAlertController(title: nil, message: "求购多少\n\(self.product!.title)?\n库存:\(product!.amount-product!.soldAmount)", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({
            textField in
            
            textField.keyboardType = .NumberPad
            textField.placeholder = "请输入想求购的数量"
            }
        )
        let okaction = UIAlertAction(title: "确定", style: .Default, handler: {
            action in
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            hud.label.text = "请求中"
            
            let textField = alert.textFields![0]
            let amount = textField.text == "" || textField.text == nil ? 1 : Int(textField.text!)
            let parameter = ["productid":self.product!.id,"amount":amount]
            Alamofire.request(.POST, orderProductURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                hud.hideAnimated(true)
                alert.removeFromParentViewController()
                switch response.result{
                case .Success:
                    if response.response?.statusCode<400{
                        OverlaySingleton.addToView(self.navigationController!.view, text: "求购发布成功,请等待卖家回复!")
                    }else{
                        let json = JSON(response.result.value!)
                        OverlaySingleton.addToView(self.navigationController!.view, text: json["error"].stringValue, duration: 3)
                    }
                case .Failure(let e):
                    print(e)
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
        })
        let cancelaction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(okaction)
        alert.addAction(cancelaction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func setupMoreView()->ChatMoreButtonView{
        var names:[String] = []
        var icons:[String] = []
        var callbacks:[()->Void] = []
        names.appendContentsOf(["照片","拍摄"])
        icons.appendContentsOf(["chatphoto.png","chatcamera.png"])
        callbacks.appendContentsOf([showAlbum,showCamera])
        let view = NSBundle.mainBundle().loadNibNamed("ChatMoreButtonView", owner: self, options: nil).first! as! ChatMoreButtonView
        view.setupView(names, icons: icons, callbacks: callbacks)
        return view
    }
    
    func showCamera(){
        dismissKeyboard()
        let vc = PhotoCameraViewController()
        
        vc.MAXPHOTO = 1
        vc.callback = {
            images in
            if images.count > 0 {
                self.sendImageMessage(images.first!)
            }
        }
        let vc2 = UINavigationController(rootViewController: vc)
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    func showAlbum(){
        dismissKeyboard()
        let vc = PhotoAlbumViewController()
        vc.MAXPHOTO = 1
        vc.callback = {
            images in
            if images.count > 0 {
                self.sendImageMessage(images.first!)
            }
        }
        let vc2 = UINavigationController(rootViewController: vc)
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    
    func toolBarDidMoveUp(height: CGFloat) {
        let y = self.collectionView.frame.origin.y
        let width = self.collectionView.frame.width
        let newHeight = self.collectionView.frame.height-height
        let offset = self.collectionView.contentOffset.y
        if height >= 0{
            UIView.animateWithDuration(0.25, animations: {
                if self._inputToolbar.keyboardisUp{
                    
                }else{
                    self.collectionView.contentOffset.y = offset + height
                    self.view.layoutIfNeeded()
                }
            }){
                finished in
                self.collectionView.frame = CGRect(x: 0, y: y, width: width, height: newHeight)
                self.collectionView.contentOffset.y = offset + height
            }
        }else{
            //do nothing
        }
    }
    
        
    
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func dismissKeyboard(){
        if _inputToolbar.barisUp{
            _inputToolbar.moveBarDown()
        }else{
            self.view.endEditing(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.navigationBar.translucent = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveMessages), name: ReceiveNewMessageNotificationName, object: nil)
        
        //collectionView!.collectionViewLayout.springinessEnabled = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var isLoading = false
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0){
            loadMoreMessageFromDatabase()
        }
    }
    
    
    func loadMoreMessageFromDatabase(){
        if !isLoading{
            isLoading = true
            
            self.title = "加载中..."
            
            if moremessage{
                let result = conversation.loadMoreMessagesFromId(firstMessageID, limit: Int32(maximumLoadCount), direction: EMMessageSearchDirectionUp)
                conversation.markAllMessagesAsRead()
                if result.count > 0 {
                    firstMessageID = (result[0] as! EMMessage).messageId
                    var tempMsg:[Message] = []
                    var tempRawMsg:[EMMessage] = []
                    var indexPaths:[NSIndexPath] = []
                    var i = 0
                    for message in result{
                        indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
                        let m = message as! EMMessage
                        
                        //if still displayed as pending then display as failed
                        if m.status == EMMessageStatusPending || m.status == EMMessageStatusDelivering{
                            m.status = EMMessageStatusFailed
                        }
                        let jsq = convertMessage(m)
                        tempMsg.append(jsq)
                        tempRawMsg.append(m)
                        i+=1
                    }
                    
                    if tempMsg.count == maximumLoadCount{
                        self.moremessage = true
                    }else{
                        self.moremessage = false
                    }
                    
                    tempMsg.appendContentsOf(messages)
                    tempRawMsg.appendContentsOf(rawmessages)
                    messages = tempMsg
                    rawmessages = tempRawMsg
                    
                    
                    
                    if messages.count <= maximumLoadCount {
                        self.collectionView?.reloadData()
                    }else{
                    
                        let contentHeight = self.collectionView!.contentSize.height
                        let offsetY = self.collectionView!.contentOffset.y
                        
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        
                        self.collectionView!.performBatchUpdates({
                            if indexPaths.count > 0 {
                                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                            }
                            }, completion: {
                                finished in
                                print("completed loading of new stuff, animating\(self.collectionView!.contentSize.height)")
                                let newContentHeight = self.collectionView.contentSize.height
                                let newOffset = offsetY + newContentHeight-contentHeight
                                self.collectionView!.contentOffset = CGPointMake(0, newOffset)
                                CATransaction.commit()
                        })
                    }
                }
            }
            
            self.title = targetNickname
            isLoading = false
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
    

    
    func convertMessage(message:EMMessage)->Message{
        var jsq:Message!
        switch message.body.type{
        case EMMessageBodyTypeText:
            let body = message.body as! EMTextMessageBody
            let displayname = (message.from == myEMUsername ? UserLoginHandler.instance.nickname : targetNickname)
            jsq = Message(senderId: message.from, displayName: displayname, text: body.text)
        case EMMessageBodyTypeImage:
            let body = message.body as! EMImageMessageBody
            let displayname = (message.from == myEMUsername ? UserLoginHandler.instance.nickname : targetNickname)
            
            let mediadata:JSQPhotoMediaItem!
            if message.direction == EMMessageDirectionSend {
                mediadata = CustomJSQPhotoMediaItem(image: UIImage(contentsOfFile: body.localPath)) // not used
            }else{
                if body.downloadStatus == EMDownloadStatusSuccessed{
                    mediadata = CustomJSQPhotoMediaItem(image: UIImage(contentsOfFile: body.localPath))
                }else{
                    mediadata = CustomJSQPhotoMediaItem(image: UIImage(contentsOfFile: body.thumbnailLocalPath))
                }
                mediadata.appliesMediaViewMaskAsOutgoing = false
            }
            
            jsq = Message(senderId: message.from, displayName: displayname, media: mediadata)
        default:
            jsq = Message(senderId: message.from, displayName: "", text: "")
        }
        switch message.status{
        case EMMessageStatusFailed:
            jsq.status = .Failed
        case EMMessageStatusPending,EMMessageStatusDelivering:
            jsq.status = .Sending
        case EMMessageStatusSuccessed:
            jsq.status = .Success
        default:
            jsq.status = .Success
        }
        return jsq
    }
    
    
    func didReceiveMessages(notification:NSNotification) {
        let json = notification.userInfo!
        let conversationid = json["id"] as! [String]
        
        if conversationid.contains(targetEMUsername){
            
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            let count = conversation.unreadMessagesCount
            let aMessages = conversation.loadMoreMessagesFromId(nil, limit: count,direction: EMMessageSearchDirectionUp)
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
    
    func sendImageMessage(image:UIImage){
        let body = EMImageMessageBody(data: UIImagePNGRepresentation(image), thumbnailData: nil)
        let from = EMClient.sharedClient().currentUsername
        let message = EMMessage(conversationID: targetEMUsername, from: from, to: targetEMUsername, body: body, ext: nil)
        message.chatType = EMChatTypeChat
        message.ext = ["em_apns_ext":["em_push_title":["\(UserLoginHandler.instance.nickname)发来了一张图片"]]]
        
        self.rawmessages.append(message)
        
        let mediadata:CustomJSQPhotoMediaItem = CustomJSQPhotoMediaItem(image: image)
        
        //used to show the overlay
        mediadata.updateProgress(0.0)
        let jsqmessage = Message(senderId: myEMUsername, displayName: UserLoginHandler.instance.nickname, media: mediadata)
        self.messages.append(jsqmessage)
        
        
        
        self.finishSendingMessageAnimated(true)
        EMClient.sharedClient().chatManager.sendMessage(message, progress: {
            progress in
            print(progress)
            let float = Float(progress) / Float(100)
            mediadata.updateProgress(float)
            }, completion: {
                message,error in
                if error == nil{
                    jsqmessage.status = .Success
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessageAnimated(false)
                }else{
                    jsqmessage.status = .Failed
                    self.finishSendingMessageAnimated(false)
                }
        })
    }
    
    func sendTextMessage(text: String!) {
        let body = EMTextMessageBody(text: text)
        let from = EMClient.sharedClient().currentUsername
        let message = EMMessage(conversationID: targetEMUsername, from: from, to: targetEMUsername, body: body, ext: nil)
        message.chatType = EMChatTypeChat
        let shortenText:String = text.characters.count > 20 ? text.substringToIndex(text.startIndex.advancedBy(19)) : text
        let ext:[NSObject:AnyObject] = ["em_apns_ext":["em_push_title":"\(UserLoginHandler.instance.nickname): "+shortenText]]
        message.ext = ext
        
        //temp sending message
        self.rawmessages.append(message)
        let jsqmessage = self.convertMessage(message)
        self.messages.append(jsqmessage)
        self.finishSendingMessageAnimated(true)
        
        EMClient.sharedClient().chatManager.sendMessage(message, progress: nil){
            message,error in
            if error == nil{ //finish sending message
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                jsqmessage.status = .Success
                self.finishSendingMessageAnimated(false)
            }else{ //send failed
                jsqmessage.status = .Failed
                self.finishSendingMessageAnimated(false)
            }
        }
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
        sendTextMessage(text)
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
            setupAvatarColor(message.senderId, incoming: true)
            return avatars[message.senderId]
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        if let accessoryView = cell.accessoryView{
            accessoryView.removeFromSuperview()
        }
        
        let message = messages[indexPath.item]
        
        switch message.status{
        case .Failed:
            let sendFailedBtn = UIButton(type:.Custom)
            sendFailedBtn.setImage(UIImage(named: "sendfailed.png"), forState: .Normal)
            sendFailedBtn.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(sendFailedBtn)
            let centerC = NSLayoutConstraint(item: sendFailedBtn, attribute: .CenterY, relatedBy: .Equal, toItem: cell.messageBubbleContainerView, attribute: .CenterY, multiplier: 1, constant: 0)
            var horizontalC:NSLayoutConstraint!
            if message.senderId == self.senderId{ // outgoing
                horizontalC = NSLayoutConstraint(item: sendFailedBtn, attribute: .Trailing, relatedBy: .Equal, toItem: cell.messageBubbleContainerView, attribute: .Leading, multiplier: 1, constant: -8)
            }else{ //incoming
                horizontalC = NSLayoutConstraint(item: sendFailedBtn, attribute: .Leading, relatedBy: .Equal, toItem: cell.messageBubbleContainerView, attribute: .Trailing, multiplier: 1, constant: 8)
            }
            let heightC = NSLayoutConstraint(item: sendFailedBtn, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
            let widthC = NSLayoutConstraint(item: sendFailedBtn, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
            sendFailedBtn.addConstraints([widthC,heightC])
            cell.contentView.addConstraints([centerC,horizontalC])
            
            cell.accessoryView = sendFailedBtn
        case .Sending:
            if !message.isMediaMessage {
                let activityindicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                activityindicator.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(activityindicator)
                let centerC = NSLayoutConstraint(item: activityindicator, attribute: .CenterY, relatedBy: .Equal, toItem: cell.messageBubbleContainerView, attribute: .CenterY, multiplier: 1, constant: 0)
                var horizontalC:NSLayoutConstraint!
                if message.senderId == self.senderId{ // outgoing
                    horizontalC = NSLayoutConstraint(item: activityindicator, attribute: .Trailing, relatedBy: .Equal, toItem: cell.messageBubbleContainerView, attribute: .Leading, multiplier: 1, constant: -8)
                }else{ //incoming
                    horizontalC = NSLayoutConstraint(item: activityindicator, attribute: .Leading, relatedBy: .Equal, toItem: cell.messageBubbleContainerView, attribute: .Trailing, multiplier: 1, constant: 8)
                }
                let heightC = NSLayoutConstraint(item: activityindicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
                let widthC = NSLayoutConstraint(item: activityindicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
                activityindicator.addConstraints([widthC,heightC])
                cell.contentView.addConstraints([centerC,horizontalC])
                activityindicator.startAnimating()
                
                cell.accessoryView = activityindicator
            }
            
        case .Success:
            break
        }
        
        if !message.isMediaMessage{
            if message.senderId == myEMUsername {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
            
            let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView!.textColor!, NSUnderlineStyleAttributeName: 1]
            cell.textView!.linkTextAttributes = attributes
        }else{
            
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        var userid:Int!
        if messages[indexPath.row].senderId == myEMUsername{
            userid = UserLoginHandler.instance.userid
        }else{
            userid = targetuserid
        }
        let vc = UserOverviewController(userid: userid)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        if rawmessages[indexPath.item].body is EMImageMessageBody { //download original image
            let body = rawmessages[indexPath.item].body as! EMImageMessageBody
            let media = messages[indexPath.row].media as! JSQPhotoMediaItem
            let previewView = ChatImagePreviewView(image: media.image)
            previewView.frame = self.navigationController!.view.frame
            previewView.alpha = 0
            self.navigationController?.view.addSubview(previewView)
            UIView.animateWithDuration(0.5, animations: {
                previewView.alpha = 1
            })
            
            
            if body.downloadStatus != EMDownloadStatusSuccessed{
                let hud = MBProgressHUD.showHUDAddedTo(previewView, animated: true)
                hud.mode = .AnnularDeterminate
                hud.userInteractionEnabled = true
                
                EMClient.sharedClient().chatManager.downloadMessageAttachment(rawmessages[indexPath.item], progress: {
                    progress in
                    hud.progress = Float(progress)/100.0
                    }, completion: {
                        message, error in
                        hud.hideAnimated(true)
                        if error == nil { //download successfull
                            let body = message.body as! EMImageMessageBody
                            let image = UIImage(contentsOfFile:body.localPath)
                            media.image = UIImage(contentsOfFile:body.localPath)
                            if let image = image{
                                previewView.setImage(image)
                            }else{ // download fail
                                OverlaySingleton.addToView(previewView, text: "图片加载失败,请稍后再试")
                            }
                        }else{ //download fail
                            OverlaySingleton.addToView(previewView, text: "图片加载失败,请稍后再试")
                        }
                })
            }
            
        }
    }
    
    
}

