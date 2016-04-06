//
//  LookAroundTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 23/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class LookAroundTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate {
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var accountID: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    var product:Product!
    var row:Int = 0
    var callback:(Int,Int)->Void = {_,_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarView.contentMode = .ScaleAspectFill
        self.avatarView.clipsToBounds = true
        
        imagesCollectionView.registerNib(UINib(nibName: "LookAroundCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LookAroundCollectionViewCell")
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.backgroundColor = UIColor.whiteColor()
        // Initialization code
    }
    
    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let min = interval/60
        if min<1{
            return "刚刚"
        }
        if min<60{
            return "\(min)分钟之前"
        }
        let hours = min/60
        if hours<24{
            return "\(hours)小时之前"
        }
        let days = hours/24
        if days<30{
            return "\(days)天之前"
        }
        return "1个月以上"
    }

    func setUpLookAroundCell(product:Product,row:Int,callback:(Int,Int)->Void){
        let sellerName = product.usernickname
        
        self.avatarView.image = UIImage(named:"defaultavatar.png")
        
        avatarView.tag = self.tag
        AvatarFactory.setupAvatarImageView(self.avatarView, avatar: product.useravatar)
        
        self.row = row
        self.callback = callback
        
        let MARGIN:CGFloat = 10
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = MARGIN
        let size = CGSize(width: self.imagesCollectionView.frame.height, height: self.imagesCollectionView.frame.height)
        layout.itemSize = size
        layout.scrollDirection = .Horizontal
        imagesCollectionView.setCollectionViewLayout(layout, animated: false)
        self.product = product
        
        
        self.accountID.text = sellerName
        let timeElapse = NSDate().timeIntervalSinceDate(product.postedTime)
        self.timeStamp.text = " "+stringFromTimeInterval(timeElapse)
        
        //price attributed string
        let currentPrice = NSMutableAttributedString(string: product.getCurrentPriceWithCurrency()+" ")
        currentPrice.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSMakeRange(0, currentPrice.length))
        currentPrice.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(20), range: NSMakeRange(0, currentPrice.length))
        let usualPrice = NSMutableAttributedString(string: product.getOriginalPriceWithCurrency())
        usualPrice.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(0, usualPrice.length))
        usualPrice.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, usualPrice.length))
        usualPrice.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: NSMakeRange(0, usualPrice.length))
        currentPrice.appendAttributedString(usualPrice)
        self.priceLabel.attributedText = currentPrice
        
        self.descriptionLabel.text = product.description == nil ? "" : product.description!
        
        //
        let attachment = NSTextAttachment()
        let im = UIImage(named: "location.png")!
        let height = self.locationLabel.frame.height*0.5
        let scale = height/im.size.height
        attachment.image = UIImage(CGImage: im.CGImage!, scale: 1/scale, orientation: .Up)
        let attachmentString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        let string = NSAttributedString(string: " "+product.getLocation())
        attachmentString.appendAttributedString(string)
        attachmentString.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(0, attachmentString.length))
        self.locationLabel.attributedText = attachmentString
        
        self.imagesCollectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LookAroundCollectionViewCell", forIndexPath: indexPath) as! LookAroundCollectionViewCell
        let tap = UITapGestureRecognizer(target: self, action: #selector(LookAroundTableViewCell.handleTap(_:)))
        cell.addGestureRecognizer(tap)
        cell.index = indexPath.row
        
        //small prefix for thumbnail
        let uuid = "small-"+self.product.imageUUID[indexPath.row]
        let fileURL = RetrieveImageFromS3.localDirectoryOf(uuid)
        
        
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!){
            cell.setImage(UIImage(contentsOfFile: fileURL.path!)!)
        }else{
            cell.setImage(UIImage(named: "loading.png")!)
            RetrieveImageFromS3.instance.retrieveImage(uuid,bucket: S3ImagesBucketName){
                bool in
                if bool{
                    self.imagesCollectionView.reloadItemsAtIndexPaths([indexPath])
                }else{//TODO: download image fail
                    
                }
            }
        }
        return cell
    }
    
    func handleTap(tap:UITapGestureRecognizer){
        let view = tap.view! as! LookAroundCollectionViewCell
        callback(row,view.index)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)
        if view == nil { return nil}
        if view!.isKindOfClass(UICollectionView){
            return self
        }
        return view
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.product.imageUUID.count
    }
    
}
