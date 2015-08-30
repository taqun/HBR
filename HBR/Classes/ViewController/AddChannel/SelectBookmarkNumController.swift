//
//  SelectBookmarkNumController.swift
//  HBR
//
//  Created by taqun on 2014/11/04.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class SelectBookmarkNumController: UITableViewController {
    
    var addNewChannelViewController: AddNewChannelViewController!
    
    let bookmarkNums = [1, 3, 5, 100, 500]
    private var bookmarkNum:Int = 0
    
    
    /*
     * Public Method
     */
    func selectBookmarkNum(num: Int){
        bookmarkNum = num
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "ブックマーク数"
        
        Logger.sharedInstance.track("AddNewChannelView/Keyword/SelectBookmarkNum")
    }
    
    
    /*
     * UITableViewDataSource Protocol
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        var index = indexPath.indexAtPosition(1)
        
        if bookmarkNums[index] == bookmarkNum {
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
        
        bookmarkNum = bookmarkNums[index]
        addNewChannelViewController.bookmarkNum = bookmarkNum

        tableView.reloadData()
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }

}
