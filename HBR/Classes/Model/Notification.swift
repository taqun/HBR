//
//  Notification.swift
//  HBR
//
//  Created by taqun on 2015/08/31.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class Notification: NSObject {
    
    static let FEED_LOADED: String                          = "feedLoadedNotification"
    static let MY_BOOKMARKS_LOADED: String                  = "myBookmarksLoadedNotification"
    
    static let BOOKMARK_LOAD_START: String                  = "bookmarkLoadStartNotification"
    static let BOOKMARK_LOADED: String                      = "bookmarkLoadedNotification"
    
    static let BOOKMARK_COUNT_UPDATED: String               = "bookmarkCountUpdatedNotification"
    
    static let TRANSACTION_STATE_CHANGED: String            = "transactionStateChangedNotification"
    static let RESTORE_TRANSACTION_STATE_CHANGED: String    = "restoreTransactionStateChangedNotification"
    static let GET_PRODUCT_INFO: String                     = "getProductInfoNotification"
    
    static let READY_OAUTH:String                           = "readyOAuthNotification"
    static let OAUTH_COMPLETE: String                       = "oAuthCompleteNotification"
   
}
