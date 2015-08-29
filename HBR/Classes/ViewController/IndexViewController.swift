//
//  IndexViewController.swift
//  HBR
//
//  Created by taqun on 2014/09/17.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import iAd

class IndexViewController: UITableViewController {
    
    @IBOutlet var btnSettings: UIBarButtonItem!
    
    private var addNewFeedCellIsShowing: Bool = false
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.registerNib(UINib(nibName: "IndexTableViewCell", bundle: nil), forCellReuseIdentifier: "IndexTableViewCell")
        self.tableView.registerNib(UINib(nibName: "AddNewFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "AddNewFeedTableViewCell")
        
        let backBtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBtn
        
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
        
        //self.navigationItem.rightBarButtonItem  = btnEdit
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem   = btnSettings
        
        // toolbar
        self.navigationController?.toolbarHidden = true
        
        
        // tableview
        if let indexPath = self.tableView?.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        var cells = self.tableView.visibleCells() as! [UITableViewCell]
        for cell in cells {
            if let indexCell = cell as? IndexTableViewCell {
                indexCell.updateView()
            }
        }
        
        // Ads
        self.canDisplayBannerAds = ModelManager.sharedInstance.adsEnabled
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("feedLoaded"), name: "FeedLoadedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("viewWillAppear:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        Logger.sharedInstance.track("IndexView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.editing = false
    }
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        let channelNum = ModelManager.sharedInstance.channelCount
        let indexPath = NSIndexPath(forRow: channelNum, inSection: 1)
        
        if self.editing == true && addNewFeedCellIsShowing == false {
            addNewFeedCellIsShowing = true
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
        } else if self.editing == false && addNewFeedCellIsShowing == true {
            addNewFeedCellIsShowing = false
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
        }
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
                var channelNum = ModelManager.sharedInstance.channelCount
                
                if self.editing == true {
                    return channelNum + 1
                } else {
                    return channelNum
                }
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
        
        let section = indexPath.indexAtPosition(0)
        let index = indexPath.indexAtPosition(1)

        switch section {
            case 0:
                var cell = tableView.dequeueReusableCellWithIdentifier("IndexTableViewCell") as! IndexTableViewCell
                
                switch index {
                    case 0:
                        cell.type = IndexTableViewCellType.UnreadItems
                    
                    case 1:
                        cell.type = IndexTableViewCellType.AllItems
                    
                    case 2:
                        let channel = ModelManager.sharedInstance.myBookmarksChannel
                        cell.type = IndexTableViewCellType.Feed
                        cell.channel = channel

                    default:
                        break
                }
            
                return cell
            
            case 1:
                let channelNum = ModelManager.sharedInstance.channelCount
                
                if self.editing == true && index == channelNum {
                    var cell = tableView.dequeueReusableCellWithIdentifier("AddNewFeedTableViewCell") as! UITableViewCell
                    return cell
                    
                } else {
                    var cell = tableView.dequeueReusableCellWithIdentifier("IndexTableViewCell") as! IndexTableViewCell
                    
                    let channel = ModelManager.sharedInstance.getChannel(index)
                    cell.type = IndexTableViewCellType.Feed
                    cell.channel = channel
                    
                    return cell
                }

            default:
                var cell = tableView.dequeueReusableCellWithIdentifier("IndexTableViewCell") as! IndexTableViewCell
                return cell
        }
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
            if self.editing == true {
                return UITableViewCellEditingStyle.Delete
            } else {
                return UITableViewCellEditingStyle.None
            }
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let fromIndex   = sourceIndexPath.row
        let toIndex     = destinationIndexPath.row
        
        ModelManager.sharedInstance.moveChannel(fromIndex, toIndex: toIndex)
    }
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        
        if proposedDestinationIndexPath.section == 1 && proposedDestinationIndexPath.row == ModelManager.sharedInstance.channelCount {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            if indexPath.section == 1 && indexPath.row == ModelManager.sharedInstance.channelCount {
                return false
            } else {
                return true
            }
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            if indexPath.section == 1 && indexPath.row == ModelManager.sharedInstance.channelCount {
                return false
            } else {
                return true
            }
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
                
                if self.editing == true && index == ModelManager.sharedInstance.channelCount {
                    self.didAdd()
                } else {
                    let channel = ModelManager.sharedInstance.getChannel(index)
                    let feedTableViewController = FeedTableViewController(channel: channel)
                    self.navigationController?.pushViewController(feedTableViewController, animated: true)
                }
            
            default:
                break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

}
