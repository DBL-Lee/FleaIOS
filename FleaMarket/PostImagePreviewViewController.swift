//
//  PostImagePreviewViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 27/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PostImagePreviewViewController: UIViewController {
    var mainImageCallBack:Int->Void = {_ in }
    var deleteImageCallBack:Int->Void = {_ in}
    var id:Int = 0
    var im:UIImage!
    var mainTitle = "设为主图"
    var mainTitleIsButton = false
    
    var imageView: UIImageView = UIImageView()
    var button3 = UIButton(type: .Custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        let button = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PostImagePreviewViewController.dismiss))
        button.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = button
        
        let button2 = UIBarButtonItem(title: "删除", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PostImagePreviewViewController.delete as (PostImagePreviewViewController) -> () -> ()))
        button2.tintColor = UIColor.redColor()
        self.navigationItem.rightBarButtonItem = button2
       
        button3.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button3.setTitle(mainTitle, forState: .Normal)
        button3.setTitleColor(UIColor.yellowColor(), forState: .Normal)
        if mainTitleIsButton{
            button3.addTarget(self, action: #selector(PostImagePreviewViewController.setMainIm), forControlEvents: .TouchUpInside)
        }
        self.navigationItem.titleView = button3
        self.view.backgroundColor = UIColor.blackColor()
        self.view.addSubview(imageView)
    }
    
    
    func dismiss(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func delete(){
        deleteImageCallBack(id)
        dismiss()
    }
    
    func setMainIm(){
        mainImageCallBack(id)
        dismiss()
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.edgesForExtendedLayout = .None
        
        
        imageView.frame = self.view.frame
        button3.setTitle(mainTitle, forState: .Normal)
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = im
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
