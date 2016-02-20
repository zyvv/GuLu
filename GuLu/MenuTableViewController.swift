//
//  MenuTableViewController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/18.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var selectedIndexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    private let titlesArray = [["所有", "大胸妹", "小翘臀", "黑丝袜", "美腿控", "有颜值", "大杂烩"] ,["福利"], ["美拍"]]
    private let menuCellID = "menuCell"
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollEnabled = false
        self.clearsSelectionOnViewWillAppear = false
        tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .Top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titlesArray.count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titlesArray[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(menuCellID)

        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: menuCellID)
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = guluMainTitleColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = guluMainTintColor().colorWithAlphaComponent(0.9)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = titlesArray[indexPath.section][indexPath.row]

        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath == selectedIndexPath) {
            return
        }
        
        selectedIndexPath = indexPath
        
        switch indexPath.section {
        case 0, 1:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let glCollectionViewController = mainStoryboard.instantiateViewControllerWithIdentifier("GLCollectionViewController") as! GLCollectionViewController
            glCollectionViewController.title = titlesArray[indexPath.section][indexPath.row]
            if indexPath.section == 1 {
                glCollectionViewController.currentItemNumber = -1
            } else {
                glCollectionViewController.currentItemNumber = indexPath.row
            }
            
            sideMenuController()?.setContentViewController(glCollectionViewController)
            break
        case 2:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let mpCollectionViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MPCollectionViewController") as! MPCollectionViewController
            mpCollectionViewController.title = titlesArray[indexPath.section][indexPath.row]
            sideMenuController()?.setContentViewController(mpCollectionViewController)
            break
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch kScreenHeight() {
        case 480, 568:
            return 44
        default:
            return 60
            
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    

}
