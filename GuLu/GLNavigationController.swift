//
//  GLNavigationController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/18.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit
import ENSwiftSideMenu

class GLNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MenuTableViewController(), menuPosition: .Left)
        switch kScreenWidth()
        {
        case 320, 375:
            
            sideMenu?.menuWidth = 100
            
        case 414:
            
            sideMenu?.menuWidth = 130
            
        default:
            
            sideMenu?.menuWidth = 100
        }
        sideMenu?.bouncingEnabled = false
        view.bringSubviewToFront(navigationBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
