//
//  CustomizedTabBarController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 24/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MBProgressHUD
class CustomizedTabBarController: UITabBarController,UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor.orangeColor()
        
        self.tabBar.translucent = false
        let height = self.tabBar.frame.height
        button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: height, height: height)
        button.setBackgroundImage(UIImage(named: "post.png"), forState: .Normal)
        

        button.center = CGPoint(x: self.tabBar.center.x, y: height/4)
        self.delegate = self
        button.addTarget(self, action: #selector(CustomizedTabBarController.postNewItem), forControlEvents: .TouchUpInside)
        self.tabBar.addSubview(button)
        button.layer.zPosition = 999999999
        
        let home = tabBar.items![0]
        home.image = UIImage(named: "home.png")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let follow = tabBar.items![1]
        follow.image = UIImage(named: "follow.png")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let message = tabBar.items![3]
        message.image = UIImage(named: "message.png")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let mine = tabBar.items![4]
        mine.image = UIImage(named: "mine.png")?.imageWithRenderingMode(.AlwaysTemplate)
    }
    var button:UIButton!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let conversations = EMClient.sharedClient().chatManager.getAllConversations()
        var unread = 0
        for con in conversations{
            let conversation = con as! EMConversation
            unread += Int(conversation.unreadMessagesCount)
        }
        if unread == 0{
            self.tabBar.items![3].badgeValue = nil
        }else{
            self.tabBar.items![3].badgeValue = "\(unread)"
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveMessages), name: ReceiveNewMessageNotificationName, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.bringSubviewToFront(button)
    }
    
    func didReceiveMessages(notification:NSNotification) {
        let userinfo = notification.userInfo!
        let count = userinfo["count"] as! Int
        if let badge = self.tabBar.items![3].badgeValue{
            self.tabBar.items![3].badgeValue = "\(Int(badge)!+count)"
        }else{
            self.tabBar.items![3].badgeValue = "\(count)"
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController==self.viewControllers![2]{
            return false
        }
        return true
    }
    
    func postNewItem(){
        if UserLoginHandler.instance.loggedIn(){ // logged in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let camera = UIAlertAction(title: "使用相机", style: UIAlertActionStyle.Default, handler: {
                _ in
                self.showCamera()
            })
            let album = UIAlertAction(title: "使用相册", style: .Default, handler: {
                _ in
                self.showAlbum()
            })
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: {
                _ in
                alert.dismissViewControllerAnimated(true, completion: {})
            })
            alert.addAction(camera)
            alert.addAction(album)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: {})
        }else{//not logged in
            let vc = UserLoginViewController(nibName: "UserLoginViewController", bundle: nil)
            let navi = UINavigationController(rootViewController: vc)
            navi.hidesBottomBarWhenPushed = true
            self.presentViewController(navi, animated: true, completion: nil)
        }
    }
    
    func finishPostingItem(){
        let firstVC = (self.viewControllers![0] as! UINavigationController).viewControllers[0] as! FirstScreenViewController
        firstVC.refresh()
    }
    
    func showCamera(){
        let vc = PhotoCameraViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.callback = presentPostView
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    func showAlbum(){
        let vc = PhotoAlbumViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.callback = presentPostView
        self.presentViewController(vc2, animated: true, completion: nil)
    }
    
    func presentPostView(images:[UIImage]){
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = "处理图片中"
        let vc = PostItemTableViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.images = images
        vc.callback = finishPostingItem
        self.presentViewController(vc2, animated: true){
            _ in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }

}
