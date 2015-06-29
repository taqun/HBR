//
//  BookmarkTableViewCell.swift
//  HBR
//
//  Created by taqun on 2014/10/04.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

import SDWebImage

class BookmarkTableViewCell: UITableViewCell {
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    
    /*
     * Initialize
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    /*
     * Public Method
     */
    func setItem(item: BookmarkItem){
        self.usernameLabel.text = item.user
        self.dateLabel.text     = item.dateString
        self.commentLabel.text  = item.comment
        
        iconView.sd_setImageWithURL(NSURL(string: item.iconUrl))
    }
    
    
    /*
     * Getter, Setter
     */
    var height: CGFloat {
        get {
            let topY            = 30
            let marginBottom    = 13
            
            let text = self.commentLabel.text as NSString!
            let maxSize = CGSize(width: self.commentLabel.frame.width, height: CGFloat.max)
            let attr = [NSFontAttributeName: self.commentLabel.font]
            let size = text.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attr, context: nil).size
            
            return CGFloat(topY + marginBottom) + ceil(size.height)
        }
    }

}
