//
//  ProductDetailTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ProductDetailTableViewController: UITableViewController {
    
    var product:Product!
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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationItem.hidesBackButton = true
        let image = UIImage(named: "backButton.png")
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
    }
    
    func dismiss(){
        self.navigationController?.popViewControllerAnimated(true)
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
            cell.setupCell(product.useravatar, sellername: product.usernickname, soldItemCount: 107, goodFeedBack: 100)
            cell.selectionStyle = .None
            return cell
        case 信息:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailDetailTableViewCell", forIndexPath: indexPath) as! ProductDetailDetailTableViewCell
            cell.setupCell(product.amount, date: product.postedTime, brandNew: product.brandNew, bargain: product.bargain, exchange: product.exchange)
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if separator.contains(indexPath.row){
            return 30
        }
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSectionsInTableView(self.tableView)-1{
            return 44
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == numberOfSectionsInTableView(self.tableView)-1{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let postBtn = UIButton(frame: view.frame)
            postBtn.backgroundColor = UIColor.orangeColor()
            postBtn.tintColor = UIColor.whiteColor()
            postBtn.setTitle("购买", forState: .Normal)
            postBtn.addTarget(self, action: "buyNow", forControlEvents: .TouchUpInside)
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
    
    func buyNow(){
        
    }
}
