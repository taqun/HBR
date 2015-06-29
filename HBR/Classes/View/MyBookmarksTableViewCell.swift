//
//  MyBookmarksTableViewCell.swift
//  HBR
//
//  Created by taqun on 2015/05/07.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class MyBookmarksTableViewCell: FeedTableViewCell {
    
    
    /*
     * Public Method
     */
    override func setFeedItem(item: Item) {
        self.item = item
        
        self.updateCell()
    }
    
    override func updateView() {
        self.updateCell()
    }
    
    
    /*
     * Private Method
     */
    private func updateCell() {
        titleLabel.text    = item.title
        
        favicon.sd_setImageWithURL(NSURL(string: "http://favicon.st-hatena.com/?url=" + item.link))
        urlLabel.text      = item.host
        dateLabel.text     = item.dateString
        
        if item.read == true {
            titleLabel.textColor = UIColor.lightGrayColor()
            urlLabel.textColor = UIColor.lightGrayColor()
            dateLabel.textColor = UIColor.lightGrayColor()
        } else {
            titleLabel.textColor = UIColor(hex: 0x333333, alpha: 1.0)
            urlLabel.textColor = UIColor.darkGrayColor()
            dateLabel.textColor = UIColor.darkGrayColor()
        }
    }
    
}
