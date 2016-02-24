//
//  PhotoAlbumViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 26/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import Photos

class PhotoAlbumViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var chosenImagesCollectionView: UICollectionView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var btmView: UIView!
    
    var callback:[UIImage]->Void = {_ in}
    
    let albumName = "FleaMarketAlbum"
    var photoFound = false
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    let imagesPerColumn = 4
    let INSET:CGFloat = 4
    var selectedIndex:[Int] = []
    
    var MAXPHOTO = GLOBAL_MAXIMUMPHOTO
    
    let cachingImageManager = PHCachingImageManager()
    var assets: [PHAsset] = [] {
        willSet {
            cachingImageManager.stopCachingImagesForAllAssets()
        }
        
        didSet {
            cachingImageManager.startCachingImagesForAssets(self.assets,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .AspectFit,
                options: nil
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageCollectionView.backgroundColor = UIColor.whiteColor()
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.registerNib(UINib(nibName: "PhotoThumbnailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoThumbnailCollectionViewCell")
        
        
        self.chosenImagesCollectionView.delegate = self
        self.chosenImagesCollectionView.dataSource = self
        self.chosenImagesCollectionView.registerClass(PhotoChosenCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoChosenCollectionViewCell")
        
        self.navigationController?.edgesForExtendedLayout = .None
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.title = "相机胶卷"
        let button = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "dismiss")
        button.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = button
        
        self.confirmBtn.titleLabel?.textAlignment = .Center
        self.confirmBtn.titleLabel?.numberOfLines = 2
        self.confirmBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.confirmBtn.setTitle("确定\n\(selectedIndex.count)/\(MAXPHOTO)", forState: .Normal)
        
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
        
        if let first_Obj:AnyObject = collection.firstObject{
            self.photoFound = true
            self.assetCollection = first_Obj as! PHAssetCollection
        }else{
            self.photoFound = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = INSET
        layout.minimumLineSpacing = INSET
        let side = (self.view.frame.width-INSET*2-INSET*CGFloat(imagesPerColumn-1))/CGFloat(imagesPerColumn)
        layout.itemSize = CGSize(width: side, height: side)
        layout.scrollDirection = .Vertical
        layout.sectionInset = UIEdgeInsets(top: INSET, left: INSET, bottom: INSET, right: INSET)
        self.imageCollectionView.setCollectionViewLayout(layout, animated: false)
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.minimumInteritemSpacing = INSET
        layout2.minimumLineSpacing = INSET
        layout2.scrollDirection = .Horizontal
        let side2 = self.btmView.frame.height-INSET*2
        layout2.itemSize = CGSize(width: side2, height: side2)
        layout2.sectionInset = UIEdgeInsets(top: INSET, left: INSET, bottom: INSET, right: INSET)
        self.chosenImagesCollectionView.setCollectionViewLayout(layout2, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Get size of the collectionView cell for thumbnail image
        if let layout = self.imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            self.assetThumbnailSize = CGSizeMake(cellSize.width, cellSize.height)
        }
        
        //fetch the photos from collection and sort newest first
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
        self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: fetchOption)
        
        self.imageCollectionView.reloadData()
    }

    func dismiss(){
        print(self.view.frame.width)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView==self.chosenImagesCollectionView{
            return selectedIndex.count
        }
        var count: Int = 0
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        if collectionView==self.chosenImagesCollectionView{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoChosenCollectionViewCell", forIndexPath: indexPath) as! PhotoChosenCollectionViewCell
            let asset: PHAsset = self.photosAsset[selectedIndex[indexPath.item]] as! PHAsset
            
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.assetThumbnailSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
                if let image = result {
                    cell.setupCell(image, id: self.selectedIndex[indexPath.item], callback: self.chosenImage,tapHandler: self.presentPreviewVC)
                }
            })
            return cell
        }
        
        let cell: PhotoThumbnailCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoThumbnailCollectionViewCell", forIndexPath: indexPath) as! PhotoThumbnailCollectionViewCell
        
        //Modify the cell
        let asset: PHAsset = self.photosAsset[indexPath.item] as! PHAsset
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.assetThumbnailSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
            if let image = result {
                cell.setThumbnailImage(image,selected:self.selectedIndex.contains(indexPath.row), id: indexPath.row, callback: self.chosenImage)
            }
        })
        return cell
    }
    let previewVC = PostImagePreviewViewController()
    
    func presentPreviewVC(id:Int){
        let asset: PHAsset = self.photosAsset[id] as! PHAsset
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
            if let image = result {
                
                self.previewVC.mainTitle = "\(self.selectedIndex.indexOf(id)!+1)/\(self.selectedIndex.count)"
                self.previewVC.im = image
                self.previewVC.id = id
                self.previewVC.deleteImageCallBack = self.chosenImage
                self.navigationController?.pushViewController(self.previewVC, animated: true)
            }
        })
    }
    
    func chosenImage(id:Int){
        var delete = false
        var add = false
        var index = 0
        if selectedIndex.contains(id){
            delete = true
            index = selectedIndex.indexOf(id)!
            assets.removeAtIndex(index)
            selectedIndex.removeAtIndex(index)
        }else{
            if selectedIndex.count<MAXPHOTO{
                add = true
                assets.append(self.photosAsset[id] as! PHAsset)
                selectedIndex.append(id)
            }
        }
        
        self.imageCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: id, inSection: 0)])
        if delete{
            self.chosenImagesCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            var indexPaths = [NSIndexPath]()
            for j in index..<self.selectedIndex.count{
                indexPaths.append(NSIndexPath(forItem: j, inSection: 0))
            }
            self.chosenImagesCollectionView.reloadItemsAtIndexPaths(indexPaths)
        }else if add{
            self.chosenImagesCollectionView.reloadData()
            self.chosenImagesCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: selectedIndex.count-1, inSection: 0), atScrollPosition: .Right, animated: true)
        }
        self.confirmBtn.setTitle("确定\n\(selectedIndex.count)/\(MAXPHOTO)", forState: .Normal)
    }
    
    
    
    @IBAction func confirmBtnPressed(sender: AnyObject) {
        var images = [UIImage]()
        let option = PHImageRequestOptions()
        option.synchronous = true
        for asset in self.assets{
            self.cachingImageManager.requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: option){
                (image,dict) in
                if image != nil{
                    images.append(image!)
                }
            }
        }
        self.dismissViewControllerAnimated(true){}
        self.callback(images)
            
    }
    

}
