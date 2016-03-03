//
//  PodsTableViewController.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/20.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import UIKit
import SafariServices

private let cellID = "cellID"

class PodsTableViewController: UITableViewController {

    let podsArray = [("Kingfisher", "https://github.com/onevcat/Kingfisher"),
                     ("ENSwiftSideMenu", "https://github.com/evnaz/ENSwiftSideMenu"),
                     ("MobilePlayer", "https://github.com/mobileplayer/mobileplayer-ios"),
                     ("Kanna", "https://github.com/mobileplayer/mobileplayer-ios"),
                     ("Alamofire", "https://github.com/Alamofire/Alamofire"),
                     ("Realm", "https://realm.io")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewController()
        
        title = "Pods"
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        cell.accessoryType = .DisclosureIndicator
        cell.backgroundColor = UIColor.whiteColor()
        
        let type = podsArray[indexPath.row]
        cell.textLabel?.text = type.0

        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let type = podsArray[indexPath.row]
        if #available(iOS 9.0, *) {
            let safariVC = SFSafariViewController(URL: NSURL(string: type.1)!)
            self.navigationController?.pushViewController(safariVC, animated: true)
        } else {
            let webVC = WebViewController()
            webVC.url = type.1
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
