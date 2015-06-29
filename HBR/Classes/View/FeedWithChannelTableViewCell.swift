//
//  FeedWithChannelTableViewCell.swift
//  
//
//  Created by taqun on 2015/04/05.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class FeedWithChannelTableViewCell: FeedTableViewCell {
    
    @IBOutlet var channelTitle: UILabel!
    
    
    /*
     * Public Method
     */
    override func setFeedItem(item: Item) {
        super.setFeedItem(item)
        
        var names = ""
        
        for channel in self.item.channels.allObjects as! [Channel] {
            if names != "" {
                names += "、"
            }
            names += channel.shortTitle
        }
        
        self.channelTitle.text = names
        
        self.updateColor()
    }
    
    override func updateView() {
        super.updateView()
        
        self.updateColor()
    }
    
    
    /*
     * Private Method
     */
    private func updateColor() {
        if item.read == true {
            channelTitle.textColor = UIColor.lightGrayColor()
        } else {
            channelTitle.textColor = UIColor.darkGrayColor()
        }
    }

}
