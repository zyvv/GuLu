//
//  AlbumCell.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/20.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit
import Kingfisher

class AlbumCell: UICollectionViewCell {

    @IBOutlet weak var albumScrollView: AlbumScrollView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        albumScrollView.imageView.image = nil

    }
    
    func configureWithImageUrl(imageUrl: String, colletionView: UICollectionView, indexPath: NSIndexPath) {

        albumScrollView.imageView.kf_setImageWithURL(NSURL(string: handleMiddleImageUrlToBigImageUrl(imageUrl))!, placeholderImage: KingfisherManager.sharedManager.cache.retrieveImageInMemoryCacheForKey(imageUrl), optionsInfo:[.Transition(ImageTransition.Fade(1))])
    }
}


class AlbumScrollView: UIScrollView, UIScrollViewDelegate {
    let imageView = UIImageView()
    
    override func awakeFromNib() {
        self.delegate = self
        imageView.frame = CGRectMake(0, 0, kScreenWidth(), kScreenHeight())
        imageView.contentMode = .ScaleAspectFit
        self.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: "handleDoubleTapGesture:")
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
        tapGesture.requireGestureRecognizerToFail(doubleTapGesture)
    }
    
    
    func handleTapGesture(tapGesture: UITapGestureRecognizer) {
        if let navigationVC = self.viewController()?.navigationController {
            navigationVC.setNavigationBarHidden(!navigationVC.navigationBarHidden, animated: true)
        }
    }
    
    func handleDoubleTapGesture(doubleTapGesture: UITapGestureRecognizer) {
        if zoomScale > 1 {
            setZoomScale(1, animated: true)
        } else {
            setZoomScale(3, animated: true)
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
}