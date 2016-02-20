//
//  MPCell.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/19.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit
import Kingfisher

class MPCell: UICollectionViewCell {
    
    @IBOutlet weak var fallImageView: UIImageView!
    
    @IBOutlet weak var loadImageErrorLabel: UILabel!
    let colorsArray = guluPlaceholderColorImage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        fallImageView.image = nil
        loadImageErrorLabel.hidden = true
    }
    
    func configureWithImageUrl(imageUrl: String, colletionView: UICollectionView, indexPath: NSIndexPath) {
        
        let i = indexPath.item % colorsArray.count
        weak var weakSelf = self
        fallImageView.kf_setImageWithURL(NSURL(string: imageUrl)!, placeholderImage: colorsArray[i], optionsInfo: [.Transition(ImageTransition.Fade(1))]) { (image, error, cacheType, imageURL) -> () in
            if error != nil {
                weakSelf!.loadImageErrorLabel.hidden = false
            }
        }
    }
}
