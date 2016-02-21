//
//  GLCollectionViewController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/18.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit
import RealmSwift

private let fallImageCellID = "FallImageCell"
private let loadMoreCellID = "LoadMoreCell"


class GLCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var currentItemNumber: Int = 0
    var imagesArray = [String]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewController()
        addLogoViewInBackground()
        
        let flowLayout = UICollectionViewFlowLayout()
        
        collectionView?.collectionViewLayout = flowLayout
        refreshControl.tintColor = guluMainTintColor()
        refreshControl.addTarget(self, action: "pullRefreshAction:", forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        self.collectionView?.registerNib(UINib(nibName: fallImageCellID, bundle: nil), forCellWithReuseIdentifier: fallImageCellID)
        self.collectionView?.registerNib(UINib(nibName: loadMoreCellID, bundle: nil), forCellWithReuseIdentifier: loadMoreCellID)

        if self.title == "首页" { // stroyBorad的title
            self.title = "咕噜"
        }
        
        let offlineDataName = currentItemNumber < 0 ? "fuli" : cidByItemNumber(currentItemNumber)
        if let realm = try? Realm(), offlineImageUrlsArrayData = OfflineImageUrlsArrayData.withName(offlineDataName , inRealm: realm) {
            if let data = offlineImageUrlsArrayData.data,  offlineImageUrlsArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) {
                self.imagesArray = offlineImageUrlsArray as! [String]
            }
        }
        
        updateItemImages(currentItemNumber)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.addObserver(self, forKeyPath: "contentInset", options: .Old, context: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.removeObserver(self, forKeyPath: "contentInset", context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentAlbumVC" {
            let albumVC = segue.destinationViewController.childViewControllers.first as! AlbumCollectionViewController
            albumVC.imageUrlsArray = self.imagesArray
            let indexPath = sender as! NSIndexPath
            albumVC.showImageFromIndex = indexPath.item
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentInset" {
            if self.collectionView!.tracking {
                guard let change = change else {
                    return
                }
                
                var oldElement: (String, AnyObject)? = nil
                for element in change {
                    if element.0 == "old" {
                        oldElement = element
                        break
                    }
                }
                
                guard let sureElement = oldElement else {
                    return
                }
                let diff = (self.collectionView?.contentInset.top)! - (sureElement.1 as! NSValue).UIEdgeInsetsValue().top
                var translation = self.collectionView?.panGestureRecognizer.translationInView(self.collectionView)
                translation?.y -= diff * 3.0 / 2.0
                self.collectionView?.panGestureRecognizer.setTranslation(translation!, inView: self.collectionView)
            }
        }
    }

    func pullRefreshAction(pullRefreshControl: UIRefreshControl) {
        updateItemImages(currentItemNumber)
    }
    
    @IBAction func showMenuTableViewController(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }


    private var currentPageIndex = 1
    private var isFetching = false
    private func updateItemImages(currentItemNumber: Int, isLoadMore: Bool = false, finish: (() -> Void)? = nil) {
        
        if isFetching {
            return
        }
        
        isFetching = true
        
        
        if isLoadMore {
            currentPageIndex++
            
        } else {
            currentPageIndex = 1
        }
        
        if currentItemNumber >= 0 {
            requestItemImages(cidByItemNumber(currentItemNumber), page: currentPageIndex, failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.isFetching = false
                    finish?()
                    })
                }) { (images) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        guard let images = images else {
                            return
                        }
                        if isLoadMore {
                            strongSelf.imagesArray += images
                            
                        } else {
                            
                            if strongSelf.refreshControl.refreshing {
                                strongSelf.refreshControl.endRefreshing()
                            }
                            strongSelf.imagesArray = images
                        }
                        
                        strongSelf.collectionView!.reloadData()
                        strongSelf.isFetching = false
                        finish?()
                        })
            }
        } else {
            requestFuliImages(currentPageIndex, failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.isFetching = false
                    finish?()
                    })
                }, completion: { (images) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        guard let images = images else {
                            return
                        }
                        if isLoadMore {
                            strongSelf.imagesArray += images
                            
                        } else {
                            
                            if strongSelf.refreshControl.refreshing {
                                strongSelf.refreshControl.endRefreshing()
                            }
                            strongSelf.imagesArray = images
                        }
                        
                        strongSelf.collectionView!.reloadData()
                        strongSelf.isFetching = false
                        finish?()
                        })
            })
        }
        
    }

    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return self.imagesArray.count
            
        case 1:
            return self.imagesArray.isEmpty ? 0 : 1
            
        default:
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(fallImageCellID, forIndexPath: indexPath) as! FallImageCell
            cell.configureWithImageUrl(self.imagesArray[indexPath.row], colletionView: self.collectionView!, indexPath: indexPath)
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(loadMoreCellID, forIndexPath: indexPath) as! LoadMoreCell
            return cell
            
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if indexPath.section == 1 {
            return CGSize(width: UIScreen.mainScreen().bounds.width, height: 80)
        }
        
        let frame: CGRect = CGRectInset(CGRectMake(0, 0, kScreenWidth()/2, kScreenWidth()/2*3/2), 3, 3);
        return CGSizeMake(frame.size.width, frame.size.height)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if section == 0 {
            return 4
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if section == 0 {
            return 4
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsetsMake(4, 4, 4, 4)
        }
        return UIEdgeInsetsZero
    }
    
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let _ = cell as? LoadMoreCell {
            updateItemImages(currentItemNumber, isLoadMore: true, finish: nil)
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("presentAlbumVC", sender: indexPath)
    }

}
