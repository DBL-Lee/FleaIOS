//
//  PreviewImagesViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import KDCircularProgress

class PreviewImagesViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate {

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var btmViewPanel: UIView!
    var imagesUUID:[String] = []
    var downloadPercentage:[Int] = []
    var currentImage:Int = 0
    var detailCallBack:Int->Void = {_ in }
    var detailButton:UIButton!
    var showDetailButton = false
    var productid:Int = 0
    
    var cachedImages:[UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "\(currentImage+1)/\(imagesUUID.count)"
        detailButton = UIButton(type: .Custom)
        detailButton.frame = CGRect(x: 0, y: 0, width: 120, height: 30
        )
        detailButton.titleLabel?.adjustsFontSizeToFitWidth = true
        detailButton.layer.borderColor = UIColor.whiteColor().CGColor
        detailButton.layer.borderWidth = 1
        detailButton.titleLabel!.font = UIFont.systemFontOfSize(15)
        detailButton.setTitle("查看详情", forState: .Normal)
        detailButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        detailButton.addTarget(self, action: #selector(PreviewImagesViewController.detailBtnPressed), forControlEvents: .TouchUpInside)
        if showDetailButton{
            self.btmViewPanel.addSubview(detailButton)
        }
        
        cachedImages = [UIImage?](count: imagesUUID.count, repeatedValue: nil)
        
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.registerNib(UINib(nibName: "PreviewImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewImagesCollectionViewCell")
        self.imagesCollectionView.pagingEnabled = true
        self.imagesCollectionView.showsHorizontalScrollIndicator = false
        
        btmViewPanel.backgroundColor = UIColor.blackColor()
        self.view.backgroundColor = UIColor.blackColor()
        
        downloadPercentage = [Int](count: imagesUUID.count, repeatedValue: 0)
        for i in 0..<imagesUUID.count{
            RetrieveImageFromS3.instance.retrieveImage(imagesUUID[i],bucket: S3ImagesBucketName,percentageHandler: {
                    percentage in
                    self.setPercentageOfItem(i, percentage: percentage)
                }){
                bool in
                    if bool{
                        self.downloadPercentage[i] = 100
                        let image = UIImage(contentsOfFile: (LocalDownloadDirectory.URLByAppendingPathComponent(self.imagesUUID[i])).path!)!
                        self.cachedImages[i] = image
                        self.imagesCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)])
                    }else{//TODO: download image fail
                        
                    }
            }
        }
    }

    
    func detailBtnPressed(){
        detailCallBack(productid)
    }
    
    override func viewDidLayoutSubviews() {
        detailButton.center = CGPoint(x: btmViewPanel.frame.width/2, y: btmViewPanel.frame.height/2)
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.imagesCollectionView.frame.height)
        self.imagesCollectionView.collectionViewLayout = layout
        imagesCollectionView.contentOffset = CGPoint(x: self.view.frame.width*CGFloat(currentImage), y: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tintColor = self.navigationController?.navigationBar.tintColor
        barTintColor = self.navigationController?.navigationBar.barTintColor
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.edgesForExtendedLayout = .None
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
    }
    var tintColor:UIColor!
    var barTintColor:UIColor!
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let barbutton = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = barbutton
        
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.barTintColor = barTintColor
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUUID.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PreviewImagesCollectionViewCell", forIndexPath: indexPath) as! PreviewImagesCollectionViewCell
        if downloadPercentage[indexPath.row]==100{
            if let image = cachedImages[indexPath.row]{
                cell.setupCell(image)
            }else{
                let image = UIImage(contentsOfFile: (LocalDownloadDirectory.URLByAppendingPathComponent(imagesUUID[indexPath.row])).path!)!
                cachedImages[indexPath.row] = image
                cell.setupCell(image)
            }
        }else{
            cell.setupProgressIndicator(downloadPercentage[indexPath.row])
        }
        return cell
    }
    
    func setPercentageOfItem(index:Int,percentage:Int){
        //only let percentage to be 100 when completion handler is called
        if percentage==100{
            downloadPercentage[index] = 99
        }else{
            downloadPercentage[index] = percentage
        }
        //only need to refresh those cells on screen
        let cells = imagesCollectionView.visibleCells() as! [PreviewImagesCollectionViewCell]
        for cell in cells{
            cell.setupProgressIndicator(downloadPercentage[(imagesCollectionView.indexPathForCell(cell))!.row])
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let  pageWidth = self.imagesCollectionView.frame.size.width
        currentImage = Int(self.imagesCollectionView.contentOffset.x / pageWidth)
        
        self.navigationItem.title = "\(currentImage+1)/\(imagesUUID.count)"
    }



}
