//
//  MPCollectionViewController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/19.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit
import MobilePlayer
import RealmSwift

private let mPCellID = "MPCell"
private let loadMoreCellID = "LoadMoreCell"

class MPCollectionViewController: UICollectionViewController {
    
    var links = [MeiPaiLinks]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewController()
        addLogoViewInBackground()
        
        let flowLayout = UICollectionViewFlowLayout()
        
        let aboutBarButtonItem = UIBarButtonItem(image: UIImage(named: "about"), style: .Plain, target: self, action: "aboutBarButtonItemAction:")
        self.navigationItem.rightBarButtonItem = aboutBarButtonItem
        
        collectionView?.collectionViewLayout = flowLayout
        refreshControl.tintColor = guluMainTintColor()
        refreshControl.addTarget(self, action: "pullRefreshAction:", forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        self.collectionView?.registerNib(UINib(nibName: mPCellID, bundle: nil), forCellWithReuseIdentifier: mPCellID)
        self.collectionView?.registerNib(UINib(nibName: loadMoreCellID, bundle: nil), forCellWithReuseIdentifier: loadMoreCellID)
        
        let showMenuTableViewControllerBarButtonItem = UIBarButtonItem(image: UIImage(named: "showMenu"), style: .Plain, target: self, action: "showMenuTableViewController:")
        self.navigationItem.leftBarButtonItem = showMenuTableViewControllerBarButtonItem
        
        if let realm = try? Realm(), offlineImageUrlsArrayData = OfflineImageUrlsArrayData.withName("meipai" , inRealm: realm) {
            if let data = offlineImageUrlsArrayData.data,  offlineImageUrlsArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) {
                let imagesArray = offlineImageUrlsArray as! [String]
                var offlineLinks = [MeiPaiLinks]()
                for url in imagesArray {
                    offlineLinks.append(MeiPaiLinks(imageUrl: url, htmlUrl: "error_url"))
                }
                self.links = offlineLinks
            }
        }
        
        updateMeiPais()

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
    
    func aboutBarButtonItemAction(barButtonItem: UIBarButtonItem) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let aboutNAVC = mainStoryboard.instantiateViewControllerWithIdentifier("AboutNavigationController")
        aboutNAVC.modalTransitionStyle = .CrossDissolve
        self.presentViewController(aboutNAVC, animated: true, completion: nil)
    }
    
    func pullRefreshAction(pullRefreshControl: UIRefreshControl) {
        updateMeiPais()
    }
    
    func showMenuTableViewController(barItem: UIBarButtonItem) {
        toggleSideMenuView()
    }
    
    
    private var currentPageIndex = 1
    private var isFetching = false
    private func updateMeiPais(isLoadMore: Bool = false, finish: (() -> Void)? = nil) {
        
        if isFetching {
            return
        }
        
        isFetching = true
        
        
        if isLoadMore {
            currentPageIndex++
            
        } else {
            currentPageIndex = 1
        }
        

        requestMeiPai(currentPageIndex, failure: { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                self?.isFetching = false
                finish?()
                })
            }, completion: { (links) -> Void in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    guard let links = links else {
                        return
                    }
                    if isLoadMore {
                        strongSelf.links += links
                        
                    } else {
                        
                        if strongSelf.refreshControl.refreshing {
                            strongSelf.refreshControl.endRefreshing()
                        }
                        strongSelf.links = links
                    }
                    
                    strongSelf.collectionView!.reloadData()
                    strongSelf.isFetching = false
                    finish?()
                    })
        })

        
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return self.links.count
            
        case 1:
            return self.links.isEmpty ? 0 : 1
            
        default:
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(mPCellID, forIndexPath: indexPath) as! MPCell
            cell.configureWithImageUrl(self.links[indexPath.row].imageUrl!, colletionView: self.collectionView!, indexPath: indexPath)
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
        
        let frame: CGRect = CGRectInset(CGRectMake(0, 0, kScreenWidth()/2, kScreenWidth()/2), 3, 3);
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
            updateMeiPais(true, finish: nil)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        weak var weakSelf = self
        requestVideo(self.links[indexPath.row].htmlUrl!, failure: { (error) -> Void in
            
            }) { (videoUrl) -> Void in
                if videoUrl == nil {
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let videoURL = NSURL(string: videoUrl!)
                    let playerVC = MobilePlayerViewController(
                        contentURL: videoURL!,
                        config: MobilePlayerConfig(
                            dictionary: [
                                "topBar": [
                                    "backgroundColor": ["#51cba4", "#51cba4"],
                                    "height": 44,
                                    "elements": [
                                    [
                                    "type": "button",
                                    "identifier": "close"
                                    ],
                                    [
                                        "type": "toggleButton",
                                        "identifier": "play",
                                        "marginLeft": 8
                                    ],
                                    [
                                    "type": "slider",
                                    "identifier": "playback",
                                    "trackHeight": 6,
                                    "trackCornerRadius": 3,
                                    "minimumTrackTintColor": "#eee",
                                    "availableTrackTintColor": "#1a9b74",
                                    "maximumTrackTintColor": "#cccccc",
                                    "thumbTintColor": "#f9f9f9",
                                    "thumbBorderWidth": 1,
                                    "thumbBorderColor": "#fff",
                                    ],
                                        ["type": "label",
                                        "identifier": "remainingTime",
                                        "marginRight": 4
                                        ],
                                    ]
                                ],
                                "bottomBar": [
                                    "backgroundColor": ["#00000000", "#00000000"],
                                    "elements": [
                                    [
                                    "type": "label",
                                    "identifier": "title",
                                    "size": 1
                                    ]
                                    ]
                                ]
                        ]))
                    weakSelf!.presentMoviePlayerViewControllerAnimated(playerVC)
                })
        }

    }
    
}