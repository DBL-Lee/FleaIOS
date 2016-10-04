//
//  CategoryTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 22/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewCell: UITableViewCell,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!

    var width:CGFloat!
    var height:CGFloat!
    let nROW:Int = 2
    let nCOL:Int = 4
    var names:[String] = []
    var icons:[String] = []
    var numberOfPages:Int = 1
    let LAYOUTSPACING:CGFloat = 10
    var callback:(Int,String)->Void = {_,_ in }
    var managedObjects:[NSManagedObject] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.registerNib(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.pagingEnabled = true
        
        self.contentView.addBorder(edges: .Bottom, colour: UIColor.lightGrayColor(), thickness: 0.5)
    }
    
    func setUpCollectionView(btnNames:[NSManagedObject],callback:(Int,String)->Void){
        let layout:HorizontalPagingLayout = HorizontalPagingLayout(row: nROW, col: nCOL,margin:LAYOUTSPACING)
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        self.numberOfPages = (btnNames.count/(nCOL*nROW))+1
        
        self.managedObjects = btnNames
        
        self.names = btnNames.map{
            managedObject -> String in
            return managedObject.valueForKey("title") as! String
        }
        
        self.icons = btnNames.map{
            managedObject -> String in
            return managedObject.valueForKey("iconPath") as! String
        }
        
        self.pageControl.numberOfPages = self.numberOfPages
        self.pageControl.currentPage = 0
        
        self.callback = callback
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        callback(managedObjects[indexPath.item].valueForKey("id") as! Int,names[indexPath.item])
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
