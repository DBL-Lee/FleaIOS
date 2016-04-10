//
//  ChatMoreButtonView.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 08/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ChatMoreButtonView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var collectionView:UICollectionView!
    var numberOfPages = 0
    @IBOutlet weak var pageControl:UIPageControl!
    let nROW:Int = 2
    let nCOL:Int = 4
    var names:[String] = []
    var icons:[String] = []
    var callbacks:[()->Void] = []
    var LAYOUTSPACING:CGFloat = 20
    
    func setupView(names:[String],icons:[String],callbacks:[()->Void]){
        self.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.collectionView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        self.names = names
        self.icons = icons
        self.callbacks = callbacks
        
        let layout:HorizontalPagingLayout = HorizontalPagingLayout(row: nROW, col: nCOL,margin:LAYOUTSPACING)
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        collectionView.registerNib(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        self.numberOfPages = (names.count/(nCOL*nROW))+1
        
        self.pageControl.numberOfPages = self.numberOfPages
        self.pageControl.currentPage = 0
        
        if numberOfPages == 1{
            self.pageControl.hidden = true
        }
        
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        callbacks[indexPath.row]()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let  pageWidth = self.collectionView.frame.size.width
        self.pageControl.currentPage = Int(self.collectionView.contentOffset.x / pageWidth)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCollectionViewCell", forIndexPath: indexPath) as! CategoryCollectionViewCell
        cell.setUpButton(names[indexPath.row],icon: icons[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return names.count
    }
    
}
