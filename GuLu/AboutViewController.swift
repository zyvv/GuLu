//
//  AboutUIViewController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/20.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewController()
        title = "关于"
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        appVersionLabel.text = "版本 \(appVersion)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissSelfBarButtonItemAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
