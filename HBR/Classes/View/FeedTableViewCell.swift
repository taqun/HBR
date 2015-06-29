//
//  FeedTableViewCell.swift
//  HBR
//
//  Created by taqun on 2014/09/13.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import QuartzCore

import SDWebImage

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userNumLabel: UILabel!
    
    @IBOutlet var favicon: UIImageView!
    @IBOutlet var urlLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var item:Item!
    
    
    /*
     * Initialize
     */
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    /*
     * Public Method
     */
    func setFeedItem(item: Item) {
        self.item = item
        
        self.updateCell()
    }
    
    func updateView() {
        self.updateCell()
    }
    
    
    /*
     * Private Method
     */
    private func updateCell() {
        titleLabel.text    = item.title
        userNumLabel.text  = item.userNum
        
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
