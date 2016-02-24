//
//  PhotoCameraViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 29/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import AVFoundation
import FastttCamera

class PhotoCameraViewController: UIViewController,FastttCameraDelegate,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImagesCollectionView: UICollectionView!
    
    @IBOutlet weak var flashToggleBtn: UIButton!
    @IBOutlet weak var flashLabel: UILabel!
    
    @IBOutlet weak var changeCameraBtn: UIButton!
    
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var fastVC:FastttCamera!
    var images:[UIImage] = []
    
    var callback:[UIImage]->Void = {_ in}
    var MAXPHOTO = GLOBAL_MAXIMUMPHOTO
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.finishBtn.titleLabel?.numberOfLines = 2
        self.finishBtn.titleLabel?.textAlignment = .Center
        self.finishBtn.setTitle("完成\n0/\(MAXPHOTO)", forState: .Normal)
        
        fastVC = FastttCamera()
        fastVC.delegate = self
        self.fastttAddChildViewController(fastVC)
        
        self.flashLabel.adjustsFontSizeToFitWidth = true
        
        fastVC.cameraFlashMode = .Auto
        
        self.capturedImagesCollectionView.delegate = self
        self.capturedImagesCollectionView.dataSource = self
        self.capturedImagesCollectionView.registerClass(PhotoChosenCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoChosenCollectionViewCell")
        
        self.view.bringSubviewToFront(previewView)
        self.previewView.userInteractionEnabled = false
    }
    
    let INSET:CGFloat = 10
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = self.view.frame.width
        fastVC.view.frame = CGRect(x: 0, y: 44, width: width, height: width)
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.minimumInteritemSpacing = INSET
        layout2.minimumLineSpacing = INSET
        layout2.scrollDirection = .Horizontal
        let side2 = self.capturedImagesCollectionView.frame.height-INSET*2
        layout2.itemSize = CGSize(width: side2, height: side2)
        layout2.sectionInset = UIEdgeInsets(top: INSET, left: INSET, bottom: INSET, right: INSET)
        self.capturedImagesCollectionView.setCollectionViewLayout(layout2, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoChosenCollectionViewCell", forIndexPath: indexPath) as! PhotoChosenCollectionViewCell
        cell.setupCell(images[indexPath.row], id: indexPath.row, callback: deleteIm, tapHandler: handleTap)

        return cell
    }
    
    let previewVC = PostImagePreviewViewController()
    
    func handleTap(index:Int){
        previewVC.mainTitle = "\(index+1)/\(self.images.count)"
        previewVC.deleteImageCallBack = deleteIm
        previewVC.im = self.images[index]
        previewVC.id = index
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    func deleteIm(index:Int){
        self.images.removeAtIndex(index)
        self.finishBtn.setTitle("完成\n\(self.images.count)/\(MAXPHOTO)", forState: .Normal)
        self.capturedImagesCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        var indexPaths = [NSIndexPath]()
        for j in index..<self.images.count{
            indexPaths.append(NSIndexPath(forItem: j, inSection: 0))
        }
        self.capturedImagesCollectionView.reloadItemsAtIndexPaths(indexPaths)
    }
    
    @IBAction func flashToggle(sender: AnyObject) {
        switch fastVC.cameraFlashMode{
        case .Auto:
            fastVC.cameraFlashMode = .On
            self.flashLabel.text = "开"
        case .On:
            fastVC.cameraFlashMode = .Off
            self.flashLabel.text = "关"
        case .Off:
            fastVC.cameraFlashMode = .Auto
            self.flashLabel.text = "自动"
        }
    }
    
    @IBAction func cameraToggle(sender: AnyObject) {
        if fastVC.cameraDevice == .Rear{
            if FastttCamera.isCameraDeviceAvailable(FastttCameraDevice.Front){
                fastVC.cameraDevice = .Front
                flashToggleBtn.hidden = true
                flashLabel.hidden = true
            }
        }else{
            fastVC.cameraDevice = .Rear
            flashToggleBtn.hidden = false
            flashLabel.hidden = false
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if self.images.count<self.MAXPHOTO{
            fastVC.takePicture()
            self.previewView.backgroundColor = UIColor.blackColor()
            UIView.animateWithDuration(0.5, animations: {
                self.previewView.backgroundColor = UIColor.clearColor()
            })
        }
    }
    
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        images.append(capturedImage.scaledImage)
        self.finishBtn.setTitle("完成\n\(self.images.count)/\(MAXPHOTO)", forState: .Normal)
        self.capturedImagesCollectionView.reloadData()
        self.capturedImagesCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: self.images.count-1, inSection: 0), atScrollPosition: .Right, animated: true)
        
    }
    
    @IBAction func finishBtnPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        callback(self.images)
    }
    
    @IBAction func cancelBtnPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}