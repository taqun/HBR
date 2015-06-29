//
//  UnreadItemTableViewController.swift
//  HBR
//
//  Created by taqun on 2014/10/16.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

import MagicalRecord

class UnreadItemTableViewController: BaseItemListTableViewController, NSFetchedResultsControllerDelegate {
    
    private var fetchedResultController: NSFetchedResultsController!
    
    
    /*
     * Initialize
     */
    convenience init() {
        self.init(style: UITableViewStyle.Plain)
        
        feedTitle = "未読の記事"
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "FeedWithChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChannelFeedCell")
        
        NSFetchedResultsController.deleteCacheWithName("UnreadItemCache")
        self.initFetchedResultController()
        
        var error:NSError?
        if !self.fetchedResultController.performFetch(&error) {
            println(error)
        }
    }
    
    
    /*
     * Private Method
     */
    @objc internal override func feedLoaded() {
        allItemNum = ModelManager.sharedInstance.getAllUnreadItemCount()
        self.tableView.reloadData()
        self.updateTitle()
        
        self.refreshControl?.endRefreshing()
    }
    
    private func initFetchedResultController() {
        if self.fetchedResultController != nil{
            return
        }
        
        var fetchRequest = Item.MR_requestAllSortedBy("date", ascending: false)
        fetchRequest.predicate = NSPredicate(format: "NOT (ANY channels == %@) AND read = false", ModelManager.sharedInstance.myBookmarksChannel)
        
        self.fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: nil, cacheName: "UnreadItemCache")
        self.fetchedResultController.delegate = self
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        let indexPath = self.tableView.indexPathForSelectedRow() as NSIndexPath!
        
        super.viewWillAppear(animated)
        
        allItemNum = ModelManager.sharedInstance.getAllUnreadItemCount()
        
        // tableView
        if indexPath != nil {
            if allItemNum > currentRowNum {
                currentRowNum -= 1
            }
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        Logger.sharedInstance.track("UnreadItemListView")
    }
    
    
    /*
     * UITableViewDataSoruce Protocol
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChannelFeedCell") as! FeedTableViewCell!
        
        if cell == nil {
            cell = FeedWithChannelTableViewCell()
        }
        
        let item = self.fetchedResultController.objectAtIndexPath(indexPath) as! Item
        cell.setFeedItem(item)
        
        return cell
    }
    
    
    /*
     * UITableViewDelegate Protocol
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.fetchedResultController.objectAtIndexPath(indexPath) as! Item
        
        let webViewController = WebViewController(item: item)
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 98
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
