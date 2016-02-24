//
//  HorizontalPagingLayout.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 22/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit


//custom layout class to ensure collection view elements
//to go from left to right up to down and then to next page
//and margin between each element
class HorizontalPagingLayout: UICollectionViewLayout {
    var cellCount = 0
    var boundSize:CGSize = CGSize()
    var itemSize:CGSize!
    var verticalItemsCount:Int!
    var horizontalItemsCount:Int!
    var itemsPerPage:Int!
    var margin:CGFloat!
    
    init(row:Int,col:Int,margin:CGFloat) {
        super.init()
        self.verticalItemsCount = row
        self.horizontalItemsCount = col
        self.itemsPerPage = verticalItemsCount*horizontalItemsCount
        self.margin = margin
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareLayout() {
        cellCount = self.collectionView!.numberOfItemsInSection(0)
        boundSize = self.collectionView!.bounds.size
        itemSize = CGSize(width: (boundSize.width-margin*CGFloat(horizontalItemsCount+1))/CGFloat(horizontalItemsCount), height: (boundSize.height-margin)/CGFloat(verticalItemsCount))
    }
    
    
    override func collectionViewContentSize() -> CGSize {
        let itemsPerPage = verticalItemsCount*horizontalItemsCount
        let numberOfItems = cellCount
        let numberOfPages = numberOfItems/itemsPerPage+1
        return CGSize(width: boundSize.width*CGFloat(numberOfPages), height: boundSize.height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttr:[UICollectionViewLayoutAttributes]? = []
        for i in 0..<cellCount{
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let attr = self.layoutAttributesForItemAtIndexPath(indexPath)
            allAttr?.append(attr!)
        }
        return allAttr
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let row = indexPath.row
        let bounds = self.collectionView!.bounds
        
        let columnPosition = row%horizontalItemsCount
        let rowPosition = (row/horizontalItemsCount)%verticalItemsCount
        let itemPage = row/itemsPerPage
        
        var frame = CGRect.zero
        frame.origin.x = CGFloat(itemPage) * bounds.size.width + margin*CGFloat(columnPosition+1) + CGFloat(columnPosition) * itemSize.width
        frame.origin.y = CGFloat(rowPosition) * itemSize.height + margin*CGFloat(rowPosition)
        frame.size = itemSize
        
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attr.frame = frame
        
        return attr
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
