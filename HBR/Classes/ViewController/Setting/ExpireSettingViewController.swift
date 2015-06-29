//
//  ExpireSettingViewController.swift
//  HBR
//
//  Created by taqun on 2014/11/21.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class ExpireSettingViewController: UITableViewController {

    let expireInterval = [
        EntryExpireInterval.ThreeDays,
        EntryExpireInterval.OneWeek,
        EntryExpireInterval.OneMonth,
        EntryExpireInterval.None
    ]
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "エントリーの保存期間"
        
        Logger.sharedInstance.track("SettingView/ExpireSettingView")
    }
    
    
    /*
     * UITableViewDataSource Protocol
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        var index = indexPath.indexAtPosition(1)
        
        var currentInterval = ModelManager.sharedInstance.entryExpireInterval
        
        if expireInterval[index] == currentInterval{
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    
    /*
     * UITableViewDelegate Protocol
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.indexAtPosition(1)
        
        ModelManager.sharedInstance.entryExpireInterval = expireInterval[index]
        
        tableView.reloadData()
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
}
