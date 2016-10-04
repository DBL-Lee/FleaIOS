//
//  ProductDetailTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class ProductDetailTableViewController: UITableViewController,UIGestureRecognizerDelegate {
    
    var product:Product!
    var targetEMUsername:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "商品详情"
        
        self.tableView.registerNib(UINib(nibName: "ProductDetailImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailImageTableViewCell")
        self.tableView.registerNib(UINib(nibName: "ProductDetailTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailTitleTableViewCell")
        self.tableView.registerNib(UINib(nibName: "ProductDetailSellerTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailSellerTableViewCell")
        self.tableView.registerNib(UINib(nibName: "ProductDetailDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailDetailTableViewCell")
        self.tableView.registerNib(UINib(nibName: "ProductDetailDescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailDescriptionTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        if UserLoginHandler.instance.loggedIn(){
            if UserLoginHandler.instance.userid == product.userid {
                let button = UIButton(type: .Custom)
                let image = UIImage(named: "editproduct@2x.png")?.imageWithRenderingMode(.AlwaysTemplate)
                button.setImage(image, forState: .Normal)
                button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                button.addTarget(self, action: #selector(editProduct), forControlEvents: .TouchUpInside)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = .None
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if editView != nil{
            editView.removeFromSuperview()
            editView = nil
        }
    }
    
    var editView:UIView!
    var postView:UIView!
    func editProduct(){
        if editView == nil{
            editView = UIView(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.height+20, width: self.navigationController!.view.frame.width, height: self.navigationController!.view.frame.height))
            
            let width:CGFloat = 100
            let height:CGFloat = 80
            postView = UIView(frame: CGRect(x: self.view.frame.width-width-10, y: 10, width: width, height: height))
            
            postView.backgroundColor = UIColor.whiteColor()
            postView.layer.cornerRadius = 2
            
            let btn1 = UIButton(type: .Custom)
            btn1.frame = CGRect(x: 0, y: 0, width: width, height: height/2)
            btn1.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn1.addBorder(edges: .Bottom, colour: UIColor.lightGrayColor(), thickness: 0.5)
            
            let btn2 = UIButton(type: .Custom)
            btn2.frame = CGRect(x: 0, y: height/2, width: width, height: height/2)
            btn2.setTitleColor(UIColor.blackColor(), forState: .Normal)
            
            btn1.setTitle("修改商品", forState: .Normal)
            btn1.addTarget(self, action: #selector(presentEditView), forControlEvents: .TouchUpInside)
            btn1.titleLabel!.font = UIFont.systemFontOfSize(13)
            
            btn2.setTitle("下架商品", forState: .Normal)
            btn2.addTarget(self, action: #selector(deleteProduct), forControlEvents: .TouchUpInside)
            btn2.titleLabel!.font = UIFont.systemFontOfSize(13)
            
            postView.addSubview(btn1)
            postView.addSubview(btn2)
            
            editView.addSubview(postView)
            self.navigationController!.view.addSubview(editView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(editProduct))
            editView.addGestureRecognizer(tap)
            tap.delegate = self
            
            editView.hidden = true
        }
        if editView.hidden{
            editView.alpha = 0
            editView.hidden = false
            UIView.animateWithDuration(0.2, animations: {
                self.editView.alpha = 1
            })
        }else{
            UIView.animateWithDuration(0.2, animations: {
                self.editView.alpha = 0
                }, completion: {
                    success in
                    self.editView.hidden = true
            })
            
        }
        
    }
    
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer is UITapGestureRecognizer{
//            if gestureRecognizer.view == postView{
//                return false
//            }
//        }
//        return true
//    }
    
    func presentEditView(){
        self.editView.hidden = true
        let vc = PostItemTableViewController(product: product,editProductCallback: finishEditingProduct)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteProduct(){
        self.editView.hidden = true
    }
    
    
    
    func finishEditingProduct(product:Product){
        self.product = product
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    /*
        0照片
        1概述
        2卖家
    ---------------------3---------------------
        4信息
        5描述
    */
    
    let 照片 = 0, 概述 = 1, 卖家 = 2, 信息 = 4, 描述 = 6
    let separator = [3,5]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if product.description == nil || product.description == ""{
            return 5
        }
        return 7
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 照片:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailImageTableViewCell", forIndexPath: indexPath) as! ProductDetailImageTableViewCell
            cell.width = self.view.frame.width
            cell.callback = presentPreviewVC
            cell.selectionStyle = .None
            cell.setupCell(product.imageUUID)
            return cell
        case 概述:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailTitleTableViewCell", forIndexPath: indexPath) as! ProductDetailTitleTableViewCell
            cell.setupCell(product.title, price: product.getCurrentPriceWithCurrency(), originalprice: product.getOriginalPriceWithCurrency(), location: product.getLocation())
            cell.selectionStyle = .None
            return cell
        case 卖家:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailSellerTableViewCell", forIndexPath: indexPath) as!
            ProductDetailSellerTableViewCell
            UserLoginHandler.instance.getUserDetailFromCloud(product.userid, emusername: nil){
                user,bool in
                if let user = user{
                    let avatar = user.avatar
                    let nickname = user.nickname
                    let emusername = user.emusername
                    let transaction = user.transaction
                    let goodfeedback = user.goodfeedback
                    cell.tag = indexPath.row
                    cell.setupCell(avatar, sellername: nickname, soldItemCount: transaction, goodFeedBack: goodfeedback)
                    self.targetEMUsername = emusername
                }else{//load user failed
                    
                }
            }
            
            cell.setupCell(product.useravatar, sellername: product.usernickname, soldItemCount: 0, goodFeedBack: 0)
//            if UserLoginHandler.instance.loggedIn(){
//                if UserLoginHandler.instance.userid==self.product.userid{
//                    cell.chatBtn.hidden = true
//                }
//            }
            cell.selectionStyle = .None
            return cell
        case 信息:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailDetailTableViewCell", forIndexPath: indexPath) as! ProductDetailDetailTableViewCell
            cell.setupCell(product.amount-product.soldAmount, date: product.postedTime, brandNew: product.brandNew, bargain: product.bargain, exchange: product.exchange)
            cell.selectionStyle = .None
            return cell
        case 描述:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailDescriptionTableViewCell", forIndexPath: indexPath) as! ProductDetailDescriptionTableViewCell
            cell.setupCell(product.description!)
            return cell
        case let a where a==separator[0]:
            let cell = UITableViewCell()
            let label = UILabel(frame: CGRect(x: 8, y: 0, width: 80, height: 30))
            label.textColor = UIColor.lightGrayColor()
            label.font = UIFont.systemFontOfSize(15)
            label.text = "信息"
            cell.contentView.addSubview(label)
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
            cell.selectionStyle = .None
            return cell
        case let a where a==separator[1]:
            let cell = UITableViewCell()
            let label = UILabel(frame: CGRect(x: 8, y: 0, width: 80, height: 30))
            label.textColor = UIColor.lightGrayColor()
            label.font = UIFont.systemFontOfSize(15)
            label.text = "描述"
            cell.contentView.addSubview(label)
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
            cell.selectionStyle = .None
            return cell
        default:break
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row{
        case 卖家:
            let vc = UserOverviewController(userid: product.userid)
            self.navigationController!.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    
    func chat(){
        if UserLoginHandler.instance.loggedIn(){
            let vc = ChatViewController(userid: product.userid ,username: targetEMUsername, nickname: product.usernickname, avatar: product.useravatar, product: product)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            
            let vc = UserLoginViewController(nibName: "UserLoginViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if separator.contains(indexPath.row){
            return 30
        }
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSectionsInTableView(self.tableView)-1{
            if UserLoginHandler.instance.loggedIn() && UserLoginHandler.instance.userid == product.userid {
                    return 0
            }
            return 44
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == numberOfSectionsInTableView(self.tableView)-1{
            if UserLoginHandler.instance.loggedIn(){
                if UserLoginHandler.instance.userid == product.userid {
                    return nil
                }
            }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let postBtn = UIButton(frame: view.frame)
            postBtn.backgroundColor = UIColor.orangeColor()
            postBtn.tintColor = UIColor.whiteColor()
            postBtn.setTitle("联系卖家", forState: .Normal)
            postBtn.addTarget(self, action: #selector(chat), forControlEvents: .TouchUpInside)
            view.addSubview(postBtn)
            return view
        }
        return nil
    }
    
    func presentPreviewVC(imageid:Int){
        let vc = PreviewImagesViewController()
        vc.imagesUUID = product.imageUUID
        vc.currentImage = imageid
        vc.hidesBottomBarWhenPushed = true
        vc.showDetailButton = false
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
