//
//  Logger.swift
//  HBR
//
//  Created by taqun on 2014/11/09.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

import GoogleAnalytics_iOS_SDK
import iConsole

class Logger: NSObject {
    
    var tracker: GAITracker?
    
    
    /*
     * Initialize
     */
    static var sharedInstance: Logger = Logger()
    
    override init() {
        super.init()
        
        GAI.sharedInstance().trackUncaughtExceptions = true
        GAI.sharedInstance().dispatchInterval = 20
        GAI.sharedInstance().logger.logLevel = .Warning

        self.tracker = GAI.sharedInstance().trackerWithTrackingId(Setting.gaTrackingId())
    }
    
    
    /*
     * Public Method
     */
    func track(screenName: String) {
        let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as [NSObject: AnyObject]
        self.tracker?.send(build)
    }
    
    func trackFeedList(channel: Channel) {
        var screenName: String = "(unknown feed list)"
        
        switch channel.type {
            case ChannelType.Hot:
                screenName = "HotEntryItemListView"
                
            case ChannelType.New:
                screenName = "NewEntryItemListView"
                
            case ChannelType.Tag:
                screenName = "FeedItemListView/Tag"
            case ChannelType.Title:
                screenName = "FeedItemListView/Title"
            case ChannelType.Text:
                screenName = "FeedItemListView/Text"
            default:
                screenName = "FeedItemListView/(not set)"
        }
        
        let build = GAIDictionaryBuilder.createScreenView().set(screenName, forKey: kGAIScreenName).build() as [NSObject: AnyObject]
        self.tracker?.send(build)
    }
    
    
    /*
     * Static Method
     */
    class func log(text: String){
        #if DEBUG
        var date = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM'/'dd HH':'mm':'ss"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        var timestamp = formatter.stringFromDate(date)
        
        iConsole.log("\(timestamp) : \(text)", args: getVaList([]))
        #endif
    }
   
}
