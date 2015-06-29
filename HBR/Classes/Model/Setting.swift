//
//  Setting.swift
//  HBR
//
//  Created by taqun on 2015/06/29.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class Setting: NSObject {
    
    // In-App Purchase
    static var PRODUCT_ID: String! {
        get {
            if let productId = NSBundle.mainBundle().objectForInfoDictionaryKey("ProductId") as? String {
                return productId
            } else {
                return nil
            }
        }
    }
    
    // Hatena
    static var HB_CONSUMER_KEY: String! {
        get {
            if let consumerKey = NSBundle.mainBundle().objectForInfoDictionaryKey("HBConsumerKey") as? String {
                return consumerKey
            } else {
                return nil
            }
        }
    }
    
    static var HB_CONSUMER_SECRET: String! {
        get {
            if let consumerSecret = NSBundle.mainBundle().objectForInfoDictionaryKey("HBConsumerSecret") as? String {
                return consumerSecret
            } else {
                return nil
            }
        }
    }
    
    // Google Analytics
    static var GA_TRACKING_ID: String! {
        get {
            if let trackingId = NSBundle.mainBundle().objectForInfoDictionaryKey("GATrackingId") as? String {
                return trackingId
            } else {
                return nil
            }
        }
    }
    
}
