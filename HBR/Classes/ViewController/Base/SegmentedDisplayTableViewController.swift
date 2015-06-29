//
//  SegmentedDisplayTableViewController.swift
//  HBR
//
//  Created by taqun on 2014/10/26.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import iAd

class SegmentedDisplayTableViewController: UITableViewController {
    
    
    let rowNum: Int         = 100
    var allItemNum: Int     = 0
    var currentRowNum: Int  = 100
    let threshold: Int      = 80 * 2
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ads
        self.canDisplayBannerAds = ModelManager.sharedInstance.adsEnabled
    }
    
    /*
     * UITableViewDataSoruce Protocol
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allItemNum > currentRowNum {
            return currentRowNum
        } else {
            return allItemNum
        }
    }
    
    
    /*
     * UIScrollViewDelegate Protocol
     */
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let toY: CGFloat    = scrollView.contentSize.height - scrollView.frame.height
        let y: CGFloat      = scrollView.contentOffset.y
        
        if y > toY - CGFloat(threshold) {
            
            if allItemNum > currentRowNum {
                currentRowNum += rowNum
                self.tableView.reloadData()
            }
        }
    }

}
