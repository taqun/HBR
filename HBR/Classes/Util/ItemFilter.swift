//
//  ItemFilter.swift
//  HBR
//
//  Created by taqun on 2015/09/10.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class ItemFilter: NSObject {
    
    static func isValid(itemData: [String: String!]) -> (Bool) {
        if let title = itemData["title"] {
            if title.lowercaseString.rangeOfString("2ch") != nil {
                return false
            }
        }
        
        if let link = itemData["link"] {
            if link.lowercaseString.rangeOfString("2ch") != nil {
                return false
            }
        }
        
        return true
    }
}
