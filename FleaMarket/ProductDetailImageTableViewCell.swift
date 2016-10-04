//
//  ProductDetailImageTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 02/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ProductDetailImageTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate {

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    var currentImage = 0
    var imagesUUID:[String] = []
    var downloadPercentage:[Int] = []
    var width:CGFloat = 0
    var callback:Int->Void = {_ in}
    
    var cachedImages:[UIImage?] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imagesCollectionView.backgroundColor = UIColor.whiteColor()
        
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.registerNib(UINib(nibName: "LookAroundCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LookAroundCollectionViewCell")
        self.imagesCollectionView.showsHorizontalScrollIndicator = false
        self.imagesCollectionView.pagingEnabled = true
    }

    func setupCell(imagesUUID:[String]){
        self.imagesUUID = imagesUUID
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSize(width: width, height: width)
        imagesCollectionView.setCollectionViewLayout(layout, animated: false)
        imagesCollectionView.reloadData()
        let  pageWidth = width
        currentImage = Int(self.imagesCollectionView.contentOffset.x / pageWidth)
        self.pageControl.numberOfPages = imagesUUID.count
        self.pageControl.currentPage = currentImage
        
        cachedImages = [UIImage?](count: imagesUUID.count, repeatedValue: nil)
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
    
    func setPercentageOfItem(index:Int,percentage:Int){
        //only let percentage to be 100 when completion handler is called
        if percentage==100{
            downloadPercentage[index] = 99
        }else{
            downloadPercentage[index] = percentage
        }
        //only need to refresh those cells on screen
        let cells = imagesCollectionView.visibleCells() as! [LookAroundCollectionViewCell]
        for cell in cells{
            cell.setupProgressIndicator(downloadPercentage[(imagesCollectionView.indexPathForCell(cell))!.row])
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUUID.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LookAroundCollectionViewCell", forIndexPath: indexPath) as! LookAroundCollectionViewCell
        
        if downloadPercentage[indexPath.row]==100{
            if let image = cachedImages[indexPath.row]{
                cell.setImage(image)
            }else{
                let image = UIImage(contentsOfFile: (LocalDownloadDirectory.URLByAppendingPathComponent(imagesUUID[indexPath.row])).path!)!
                cachedImages[indexPath.row] = image
                cell.setImage(image)
            }
        }else{
            cell.setupProgressIndicator(downloadPercentage[indexPath.row])
        }
        return cell
    }
    
    func handleTap(tap:UITapGestureRecognizer){
        let view = tap.view as! LookAroundCollectionViewCell
        callback(view.index)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let  pageWidth = self.imagesCollectionView.frame.size.width
        currentImage = Int(self.imagesCollectionView.contentOffset.x / pageWidth)
        self.pageControl.numberOfPages = imagesUUID.count
        self.pageControl.currentPage = currentImage
    }
    
}
