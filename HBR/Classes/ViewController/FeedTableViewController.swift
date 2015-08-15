//
//  FeedTableViewController.swift
//  HBR
//
//  Created by taqun on 2014/09/12.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

class FeedTableViewController: SegmentedDisplayTableViewController, NSFetchedResultsControllerDelegate {
    
    var channel: Channel!
    
    private var fetchedResultController: NSFetchedResultsController!
    
    
    /*
     * Initialize
     */
    convenience init(channel: Channel) {
        self.init(style: UITableViewStyle.Plain)
        
        self.channel = channel
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        let backBtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBtn
        
        let checkBtn = UIBarButtonItem(image: UIImage(named: "IconCheckmark"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("didCheckmark"))
        self.navigationItem.rightBarButtonItem = checkBtn
        
        // tableview
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("didRefreshControlChanged"), forControlEvents: UIControlEvents.ValueChanged)
        
        NSFetchedResultsController.deleteCacheWithName(self.channel.title + "Cache")
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
        
        var fetchRequest = Item.requestAllSortBy("date", ascending: false)
        fetchRequest.predicate = NSPredicate(format: "ANY channels = %@", self.channel)
        
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        
        self.fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: self.channel.title + "Cache")
        self.fetchedResultController.delegate = self
    }
    
    
    @objc private func feedLoaded(){
        allItemNum = channel.items.count
        self.tableView.reloadData()
        self.updateTitle()
        
        self.refreshControl?.endRefreshing()
    }
    
    @objc private func didRefreshControlChanged() {
        FeedController.sharedInstance.loadFeed(channel.objectID)
    }
    
    @objc private func didCheckmark() {
        channel.markAsReadAllItems()
        
        self.updateTitle()
        self.updateVisibleCells()
    }
    
    private func updateVisibleCells() {
        var cells = self.tableView.visibleCells() as! [FeedTableViewCell]
        for cell: FeedTableViewCell in cells {
            cell.updateView()
        }
    }
    
    private func updateTitle() {
        let unreadCount = channel.unreadItemCount
        
        if unreadCount == 0 {
            self.title = channel.title
        } else {
            self.title = channel.title + " (" + String(unreadCount) + ")"
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
        
        if let indexPath = self.tableView?.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // tableView
        self.updateVisibleCells()
        
        allItemNum = channel.items.count
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("feedLoaded"), name: "FeedLoadedNotification", object: nil)
        
        Logger.sharedInstance.trackFeedList(self.channel)
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as! FeedTableViewCell!
        
        if cell == nil {
            cell = FeedTableViewCell()
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
