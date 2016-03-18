//
//  CustomizedTabBarController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 24/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class CustomizedTabBarController: UITabBarController,UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.translucent = false
        let height = self.tabBar.frame.height
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: height, height: height))
        button.setBackgroundImage(UIImage(named: "post.png"), forState: .Normal)
        button.center = CGPoint(x: self.tabBar.center.x, y: height/4)
        self.delegate = self
        button.addTarget(self, action: "postNewItem", forControlEvents: .TouchUpInside)
        self.tabBar.addSubview(button)
        
        
        
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
            let controller = UserLoginViewController()
            let navi = UINavigationController(rootViewController: controller)
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
        
        let vc = PostItemTableViewController()
        let vc2 = UINavigationController(rootViewController: vc)
        vc.images = images
        vc.callback = finishPostingItem
        self.presentViewController(vc2, animated: true, completion: nil)
    }

}
