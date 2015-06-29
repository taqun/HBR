//
//  BookmarkViewController.swift
//  HBR
//
//  Created by taqun on 2014/09/14.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

import MBProgressHUD

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var url: String!
    var bookmark: Bookmark!
    
    var showOnlyComment: Bool = true
    
    
    /*
     * Initialize
     */
    convenience init() {
        self.init(nibName: "BookmarkViewController", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "BookmarkTableViewCell", bundle: nil), forCellReuseIdentifier: "BookmarkCell")
        self.tableView.registerNib(UINib(nibName: "BookmarkReadMoreCell", bundle: nil), forCellReuseIdentifier: "BookmarkReadMoreCell")
        self.tableView.registerNib(UINib(nibName: "HBRBookmarkNoDataCell", bundle: nil), forCellReuseIdentifier: "BookmarkNoDataCell")
    }
    
    
    /*
     * Public Method
     */
    func setSize(rect: CGRect) {
        let frame = self.view.frame
        self.view.frame = CGRectMake(0, 0, rect.width, frame.height)
    }
    
    
    /*
     * Private Method
     */
    @objc private func didLoadBookmarks() {
        MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
    }
    
    @objc private func bookmarkLoaded(){
        self.bookmark = ModelManager.sharedInstance.getBookmark(url)
        
        if self.bookmark != nil && self.bookmark.getCommentItemCount() == 0 {
            showOnlyComment = false
        }
        
        MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
        
        self.tableView.reloadData()
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didLoadBookmarks"), name: "BookmarkLoadStartNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("bookmarkLoaded"), name: "BookmarkLoadedNotification", object: nil)
        
        FeedController.sharedInstance.loadBookmarks(self.url)
        
        Logger.sharedInstance.track("BookmarkListView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        MBProgressHUD.hideAllHUDsForView(self.navigationController?.view, animated: true)
    }
    
    
    /*
     * UITableViewDataSoruce Protocol
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.bookmark != nil {
            if showOnlyComment {
                return bookmark.getCommentItemCount() + 1
            } else {
                if bookmark.items.count == 0 {
                    return 1
                } else {
                    return bookmark.items.count
                }
            }
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: UITableViewCell! = nil
        
        if showOnlyComment {
            let index = indexPath.indexAtPosition(1)
            let count = bookmark.getCommentItemCount()
          
            if index == count {
                cell = tableView.dequeueReusableCellWithIdentifier("BookmarkReadMoreCell") as! UITableViewCell
                
                if cell == nil {
                    cell = BookmarkReadMoreCell()
                }
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("BookmarkCell") as! UITableViewCell
                
                if cell == nil {
                    cell = BookmarkTableViewCell()
                }
                
                let bookmarkItem = bookmark.getCommentItem(indexPath.indexAtPosition(1))
                
                (cell as! BookmarkTableViewCell).setItem(bookmarkItem)
            }
        } else {
            if bookmark.items.count == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("BookmarkNoDataCell") as! UITableViewCell
                
                if cell == nil {
                    cell = BookmarkNoDataCell()
                }
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("BookmarkCell") as! UITableViewCell
                
                if cell == nil {
                    cell = BookmarkTableViewCell()
                }
                
                let bookmarkItem = self.bookmark.items[indexPath.indexAtPosition(1)]
                (cell as! BookmarkTableViewCell).setItem(bookmarkItem)
            }
        }
        
        return cell!
    }
    
    /*
    * UITableViewDelegate Protocol
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if showOnlyComment {
            
            let index = indexPath.indexAtPosition(1)
            let count = bookmark.getCommentItemCount()
            
            if index == count {
                return 44
            }else {
                let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! BookmarkTableViewCell
                return cell.height
            }
            
        } else {
            
            if bookmark.items.count == 0 {
                return 44
            } else {
                let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! BookmarkTableViewCell
                return cell.height
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if showOnlyComment {
            let index = indexPath.indexAtPosition(1)
            let count = bookmark.getCommentItemCount()
            
            if index == count {
                showOnlyComment = false
                
                tableView.setContentOffset(CGPointZero, animated: false)
                tableView.reloadData()
            }
        }
    }

}
