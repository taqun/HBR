//
//  IndexViewController.swift
//  HBR
//
//  Created by taqun on 2014/09/17.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import iAd

//import GoogleAnalytics_iOS_SDK

class IndexViewController: UITableViewController {
    
    @IBOutlet var btnAdd: UIBarButtonItem!
    @IBOutlet var btnSettings: UIBarButtonItem!
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UINib(nibName: "IndexTableViewCell", bundle: nil), forCellReuseIdentifier: "IndexTableViewCell")
        
        let backBtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBtn
        
        btnAdd.target = self
        btnAdd.action = Selector("didAdd")
        
        btnSettings.target = self
        btnSettings.action = Selector("didSettings")
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("didRefreshControlChanged"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    /*
     * Private Method
     */
    @objc private func didAdd() {
        let storyBoard = UIStoryboard(name: "SelectChannelTypeViewController", bundle: nil)
        let selectChannelTypeViewController = storyBoard.instantiateInitialViewController() as! SelectChannelTypeViewController
        selectChannelTypeViewController.onComplete = self.doneAdd
        selectChannelTypeViewController.onCancel = self.cancelAdd
        
        let navigationController = NavigationControllerUtil.getNavigationController(selectChannelTypeViewController)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func doneAdd() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            self.tableView.reloadData()
        })
    }
    
    private func cancelAdd() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func didSettings() {
        let storyBoard = UIStoryboard(name: "SettingViewController", bundle: nil)
        let settingViewController = storyBoard.instantiateInitialViewController() as! SettingViewController
        settingViewController.onComplete = self.didCloseSettings
        
        let navigationController = NavigationControllerUtil.getNavigationController(settingViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func didCloseSettings() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func didRefreshControlChanged() {
        FeedController.sharedInstance.loadFeeds()
    }
    
    @objc private func feedLoaded() {
        refreshControl?.endRefreshing()
        
        var cells = self.tableView.visibleCells() as! [IndexTableViewCell]
        for cell: IndexTableViewCell in cells {
            cell.updateView()
        }
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // navigationbar
        self.title = "HBR"
        
        self.navigationItem.rightBarButtonItem = btnAdd
        self.navigationItem.leftBarButtonItem = btnSettings
        
        // toolbar
        self.navigationController?.toolbarHidden = true
        
        
        // tableview
        if let indexPath = self.tableView?.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        var cells = self.tableView.visibleCells() as! [IndexTableViewCell]
        for cell: IndexTableViewCell in cells {
            cell.updateView()
        }
        
        // Ads
        self.canDisplayBannerAds = ModelManager.sharedInstance.adsEnabled
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("feedLoaded"), name: "FeedLoadedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("viewWillAppear:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        //Logger.sharedInstance.track("IndexView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /*
     * UITableViewDataSource Protocol
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 3
            case 1:
                return ModelManager.sharedInstance.channelCount
            default:
                return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                break
            case 1:
                return "フィード"
            default:
                break
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("IndexTableViewCell") as! IndexTableViewCell!
        
        if cell == nil {
            cell = IndexTableViewCell()
        }
        
        let section = indexPath.indexAtPosition(0)
        let index = indexPath.indexAtPosition(1)
        
        switch section {
            case 0:
                switch index {
                    case 0:
                        cell.setType(HBRIndexTableViewCellType.UnreadItems, channel: nil)
                    
                    case 1:
                        cell.setType(HBRIndexTableViewCellType.AllItems, channel: nil)
                    
                    case 2:
                        cell.setType(HBRIndexTableViewCellType.MyBookmarks, channel: nil)
                    
                    default:
                        break
                }
            
            case 1:
                let channel = ModelManager.sharedInstance.getChannel(index)
                
                switch channel.type {
                    case ChannelType.Hot:
                        cell.setType(HBRIndexTableViewCellType.HotEntry, channel: channel)
                    
                    case ChannelType.New:
                        cell.setType(HBRIndexTableViewCellType.NewEntry, channel: channel)
                    
                    default:
                        cell.setType(HBRIndexTableViewCellType.Feed, channel: channel)
                }

            default:
                break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let index = indexPath.indexAtPosition(1)
            ModelManager.sharedInstance.deleteFeedChannel(index)
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let section = indexPath.indexAtPosition(0)
        
        if section == 1 {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    
    /*
     * UITableView Delegate
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.indexAtPosition(0)
        let index = indexPath.indexAtPosition(1)
        
        switch section {
            case 0:
                switch index {
                case 0:
                    let unreadItemTableViewController = UnreadItemTableViewController()
                    self.navigationController?.pushViewController(unreadItemTableViewController, animated: true)
                    
                case 1:
                    let allItemTableViewController = AllItemTableViewController()
                    self.navigationController?.pushViewController(allItemTableViewController, animated: true)
                    
                case 2:
                    let myBookmarksTableViewController = MyBookmarksTableViewController()
                    self.navigationController?.pushViewController(myBookmarksTableViewController, animated: true)
                default:
                    break
            }
            
            case 1:
                let channel = ModelManager.sharedInstance.getChannel(index)
                let feedTableViewController = FeedTableViewController(channel: channel)
                self.navigationController?.pushViewController(feedTableViewController, animated: true)
            
            default:
                break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

}
