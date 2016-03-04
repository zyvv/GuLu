//
//  AlbumCollectionViewController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/20.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit

private let albumCellID = "AlbumCell"

class AlbumCollectionViewController: UICollectionViewController {
    
    var imageUrlsArray = [String]()
    var showImageFromIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewController()

        if Float(UIDevice.currentDevice().systemVersion) < 9.0 {
            self.collectionView?.frame = CGRectMake(0, -10, kScreenWidth(), kScreenHeight())
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = self.collectionView!.bounds.size
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsZero
        self.collectionView?.collectionViewLayout = flowLayout
        self.collectionView?.pagingEnabled = true
        self.collectionView!.registerNib(UINib(nibName: albumCellID, bundle: nil), forCellWithReuseIdentifier: albumCellID)
        self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: showImageFromIndex, inSection: 0), atScrollPosition: .Left, animated: false)
        self.title = "\(showImageFromIndex + 1)/\(imageUrlsArray.count)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissSelfBarButtonItemAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return imageUrlsArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(albumCellID, forIndexPath: indexPath) as! AlbumCell

        cell.configureWithImageUrl(imageUrlsArray[indexPath.item], colletionView: self.collectionView!, indexPath: indexPath)
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.title = "\(Int(scrollView.contentOffset.x / kScreenWidth() + 1))/\(imageUrlsArray.count)"
    }
    
    

}
