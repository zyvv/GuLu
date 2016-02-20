//
//  GLConfig.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/18.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit

func kScreenWidth() -> CGFloat {
    return UIScreen.mainScreen().bounds.width
}

func kScreenHeight() -> CGFloat {
    return UIScreen.mainScreen().bounds.height
}

func kRGBColor(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
}

func guluMainTitleColor() -> UIColor {
    return UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1.0)
}

func guluMainTintColor() -> UIColor {
    return UIColor(red: 81/255.0, green: 203/255.0, blue: 164/255.0, alpha: 1.0)
}

func guluPlaceholderColorImage() -> [UIImage] {
    
    var colorImageArray = [UIImage]()
     let colorsArray = [kRGBColor(69, g: 169, b: 139, alpha: 1),
                        kRGBColor(233, g: 181, b: 44, alpha: 1),
                        kRGBColor(206, g: 69, b: 52, alpha: 1),
                        kRGBColor(56, g: 136, b: 206, alpha: 1),
                        kRGBColor(41, g: 57, b: 74, alpha: 1),
                        kRGBColor(134, g: 147, b: 149, alpha: 1),
                        kRGBColor(232, g: 236, b: 238, alpha: 1),
                        kRGBColor(70, g: 153, b: 82, alpha: 1),
                        kRGBColor(58, g: 139, b: 115, alpha: 1)]

    for(var i=0; i<colorsArray.count; ++i) {
        let color = colorsArray[i]
        colorImageArray.append(colorToImage(color))
    }
    return colorImageArray
}


func colorToImage(color: UIColor) -> UIImage {
    let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

func handleMiddleImageUrlToBigImageUrl(middleImageUrl: String) -> String {
    if middleImageUrl.containsString("bmiddle") {
        return middleImageUrl.stringByReplacingOccurrencesOfString("bmiddle", withString: "large")
    }
    return middleImageUrl
}


extension UIView {
    func viewController() -> UIViewController? {
        var next: UIResponder? = self.nextResponder()
        repeat {
            if next!.isKindOfClass(UIViewController.self) {
                return next as? UIViewController
            }
            next = next?.nextResponder()
        } while (next != nil)
        return nil
    }
}

extension UIViewController {
    func configViewController() {
        
        guard let navigationController = navigationController else {
            return
        }
        
        navigationController.navigationBar.backgroundColor = nil
        let textAttributes = [
            NSForegroundColorAttributeName: guluMainTitleColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(17)
        ]
        
        navigationController.navigationBar.titleTextAttributes = textAttributes
        navigationController.navigationBar.tintColor = guluMainTintColor()
    }
    
    func addLogoViewInBackground() {
        let backgroundView = NSBundle.mainBundle().loadNibNamed("BackgroudView", owner: self, options: nil).last as! UIView
        backgroundView.frame = self.view.bounds
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.insertSubview(backgroundView, atIndex: self.view.subviews.count - 1)
    }
}
