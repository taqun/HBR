//
//  IndexTableViewCell.swift
//  HBR
//
//  Created by taqun on 2014/09/21.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

enum HBRIndexTableViewCellType: String {
    case UnreadItems    = "未読の記事"
    case AllItems       = "すべての記事"
    case HotEntry       = "人気エントリー"
    case NewEntry       = "新着エントリー"
    case Feed           = "フィード"
    case MyBookmarks    = "マイブックマーク"
}

class IndexTableViewCell: UITableViewCell {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    
    var channel: Channel!
    var type: HBRIndexTableViewCellType = HBRIndexTableViewCellType.Feed
    
    
    /*
     * Public Method
     */
    func setType(type: HBRIndexTableViewCellType, channel:Channel!) {
        self.type = type
        self.channel = channel
        
        self.updateCell()
    }
    
    func updateView() {
        self.updateCell()
    }
    
    
    /*
     * Private Method
     */
    private func updateCell() {
        
        if contains([HBRIndexTableViewCellType.HotEntry, HBRIndexTableViewCellType.NewEntry, HBRIndexTableViewCellType.Feed], type) {
            titleLabel.text = channel.title
        } else {
            titleLabel.text = self.type.rawValue
        }
        
        switch type {
            case HBRIndexTableViewCellType.UnreadItems:
                iconView.image = UIImage(named: "IconInbox")
                numberLabel.text = String(ModelManager.sharedInstance.getAllUnreadItemCount())
            
            case HBRIndexTableViewCellType.AllItems:
                iconView.image = UIImage(named: "IconInboxes")
                numberLabel.hidden = true
            
            case HBRIndexTableViewCellType.HotEntry:
                iconView.image = UIImage(named: "IconHotEntry")
                numberLabel.text = String(channel.getUnreaditemCount())
            
            case HBRIndexTableViewCellType.NewEntry:
                iconView.image = UIImage(named: "IconNewEntry")
                numberLabel.text = String(channel.getUnreaditemCount())
            
            case HBRIndexTableViewCellType.Feed:
                switch channel.type {
                    case ChannelType.Tag:
                        iconView.image = UIImage(named: "IconTag")
                    case ChannelType.Title:
                        iconView.image = UIImage(named: "IconTitle")
                    case ChannelType.Text:
                        iconView.image = UIImage(named: "IconSearch")
                    default:
                        break
                }
                
                numberLabel.text = String(channel.getUnreaditemCount())
            
            case HBRIndexTableViewCellType.MyBookmarks:
                iconView.image = UIImage(named: "IconBookmark")
                numberLabel.hidden = true
            
            default:
                break
        }
    }
}
