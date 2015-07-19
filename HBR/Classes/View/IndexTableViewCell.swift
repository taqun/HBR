//
//  IndexTableViewCell.swift
//  HBR
//
//  Created by taqun on 2014/09/21.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

enum IndexTableViewCellType: String {
    case UnreadItems    = "未読の記事"
    case AllItems       = "すべての記事"
    case Feed           = "フィード"
}

class IndexTableViewCell: UITableViewCell {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    
    var type: IndexTableViewCellType!
    
    
    /*
     * Public Method
     */
    func updateView() {
        self.updateCell()
    }
    
    
    /*
     * Private Method
     */
    private func updateCell() {        
        if self.type == IndexTableViewCellType.Feed {
            self.updateFeedCell()
        } else {
            self.updateItemsCell()
        }
    }
    
    private func updateFeedCell() {
        titleLabel.text = _channel.title
        numberLabel.text = String(_channel.unreadItemCount)
        
        switch _channel.type {
            case .Hot:
                iconView.image = UIImage(named: "IconHotEntry")
            
            case .New:
                iconView.image = UIImage(named: "IconNewEntry")
            
            case .Tag:
                iconView.image = UIImage(named: "IconTag")
            
            case .Title:
                iconView.image = UIImage(named: "IconTitle")
            
            case .Text:
                iconView.image = UIImage(named: "IconSearch")
            
            case .Mine:
                iconView.image = UIImage(named: "IconBookmark")
                numberLabel.hidden = true
            
            default:
                break
        }
    }
    
    private func updateItemsCell() {
        if let type = self.type {
            titleLabel.text = type.rawValue
            
            switch type {
                case .UnreadItems:
                    iconView.image = UIImage(named: "IconInbox")
                    numberLabel.text = String(ModelManager.sharedInstance.allUnreadItemCount)
                
                case .AllItems:
                    iconView.image = UIImage(named: "IconInboxes")
                    numberLabel.hidden = true
                    
                default:
                    break
            }
        }
    }
    
    
    /*
     * Getter, Setter
     */
    private var _channel: Channel!
    var channel: Channel! {
        set {
            self._channel = newValue
            
            self.updateCell()
        }
        
        get {
            return self._channel
        }
    }
}
