//
//  MyBookmarksTableViewController.swift
//  HBR
//
//  Created by taqun on 2015/05/02.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

class MyBookmarksTableViewController: SegmentedDisplayTableViewController, NSFetchedResultsControllerDelegate {

    
    private var fetchedResultController: NSFetchedResultsController!
    
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
        self.tableView.registerNib(UINib(nibName: "MyBookmarksTableViewCell", bundle: nil), forCellReuseIdentifier: "MyBookmarksCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("didRefreshControlChanged"), forControlEvents: UIControlEvents.ValueChanged)
        
        NSFetchedResultsController.deleteCacheWithName("MyBookmarksCache")
        self.initFetchedResultsController()
        
        var error:NSError?
        if !self.fetchedResultController.performFetch(&error) {
            println(error)
        }
    }
    
    
    /*
     * Private Method
     */
    private func initFetchedResultsController() {
        if self.fetchedResultController != nil{
            return
        }
        
        let channel = ModelManager.sharedInstance.myBookmarksChannel
        var fetchRequest = Item.requestAllSortBy("date", ascending: false)
        fetchRequest.predicate = NSPredicate(format: "ANY channels = %@", channel)
        
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        
        self.fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "MyBookmarksCache")
        self.fetchedResultController.delegate = self
    }
    
    private func updateVisibleCells() {
        var cells = self.tableView.visibleCells() as! [FeedTableViewCell]
        for cell: FeedTableViewCell in cells {
            cell.updateView()
        }
    }
    
    @objc private func didRefreshControlChanged() {
        UserManager.sharedInstance.loadMyBookmarks()
    }
    
    @objc private func myBookmarksLoaded() {
        self.refreshControl?.endRefreshing()
        
        let channel = ModelManager.sharedInstance.myBookmarksChannel
        self.allItemNum = channel.items.count
        self.tableView.reloadData()
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let username = UserManager.sharedInstance.username {
            self.title = username + "のブックマーク"
        } else {
            self.title = "ブックマーク"
        }
        
        // tableView
        self.updateVisibleCells()
        
        let channel = ModelManager.sharedInstance.myBookmarksChannel
        self.allItemNum = channel.items.count
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("myBookmarksLoaded"), name: "MyBookmarksLoadedNotification", object: nil)
        
        Logger.sharedInstance.track("MyBookmarkItemListView")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserManager.sharedInstance.isLoggedIn {
            // TODO show alert
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /*
     * UITableViewDataSource Protocol
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MyBookmarksCell") as! MyBookmarksTableViewCell!
        
        if cell == nil {
            cell = MyBookmarksTableViewCell()
        }
        
        let item = self.fetchedResultController.objectAtIndexPath(indexPath) as! Item
        cell.setFeedItem(item)
        
        return cell
    }
    
    /*
     * UITableViewDelegate Protocol
     */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.fetchedResultController.objectAtIndexPath(indexPath) as! Item
        
        let webViewController = WebViewController(item: item)
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    /*
     * NSFetchedResultsControllerDelegate Protocol
     */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}
