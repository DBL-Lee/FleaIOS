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
    var downloadFinished:[Bool] = []
    var width:CGFloat = 0
    var callback:Int->Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.registerNib(UINib(nibName: "LookAroundCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LookAroundCollectionViewCell")
        self.imagesCollectionView.showsHorizontalScrollIndicator = false
        self.imagesCollectionView.pagingEnabled = true
    }

    func setupCell(imagesUUID:[String]){
        self.imagesUUID = imagesUUID
        self.downloadFinished = [Bool](count: imagesUUID.count, repeatedValue: false)
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
        
        for i in 0..<imagesUUID.count{
            RetrieveImageFromS3.retrieveImage(imagesUUID[i]){
                _ in
                self.downloadFinished[i] = true
                self.imagesCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)])
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUUID.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LookAroundCollectionViewCell", forIndexPath: indexPath) as! LookAroundCollectionViewCell
        if downloadFinished[indexPath.row]{
            let image = UIImage(contentsOfFile: (LocalDownloadDirectory.URLByAppendingPathComponent(imagesUUID[indexPath.row])).path!)!
            cell.setImage(image)
            cell.index = indexPath.row
            let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
            cell.addGestureRecognizer(tap)
        }else{
            cell.setImage(UIImage(named: "loading.png")!)
            cell.index = indexPath.row
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
