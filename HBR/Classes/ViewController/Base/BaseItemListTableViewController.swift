//
//  BaseItemListTableViewController.swift
//  HBR
//
//  Created by taqun on 2014/10/17.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class BaseItemListTableViewController: SegmentedDisplayTableViewController {
    
    var feedTitle: String!
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        let backBtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBtn
        
        // tableview
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.registerNib(UINib(nibName: "HBRFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("didRefreshControlChanged"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    /*
     * Private Method
     */
    @objc private func didRefreshControlChanged() {
        FeedController.sharedInstance.loadFeeds()
    }
    
    @objc internal func feedLoaded() {
        println("HBRBaseItemListTableViewController#feedLoaded is called. This method should be override.")
    }
    
    internal func updateTitle() {
        let unreadCount = ModelManager.sharedInstance.allUnreadItemCount
        
        if unreadCount == 0 {
            self.title = feedTitle
        } else {
            self.title = feedTitle + " (" + String(unreadCount) + ")"
        }
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // navigationbar
        self.updateTitle()
        
        // toolbar
        self.navigationController?.toolbarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("feedLoaded"), name: "FeedLoadedNotification", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /*
     * UITableViewDataSoruce Protocol
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    /*
     * UITableViewDelegate Protocol
     */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
}
