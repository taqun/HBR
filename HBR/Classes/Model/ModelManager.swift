//
//  ModelManager.swift
//  HBR
//
//  Created by taqun on 2014/09/13.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

import Alamofire

class ModelManager: NSObject {
    
    var myBookmarksChannel: MyBookmarks!
    
    private var bookmarks: [String: Bookmark] = Dictionary<String, Bookmark>()
    
    private var currentUrl: String!
    private var currentUrlsBookmarkCount: Int! = 0
    
    
    /*
     * Initialize
     */
    static var sharedInstance: ModelManager = ModelManager()
    
    override init(){
        super.init()
        
        var us = NSUserDefaults.standardUserDefaults()
        us.registerDefaults([
            "AdsEnabled" : true,
            "EntryExpireInterval" : EntryExpireInterval.OneWeek.rawValue
        ])
        
        self.initMyBookmarks()
    }
    
    private func initMyBookmarks() {
        let myBookmarksChannels = MyBookmarks.MR_findAll() as! [MyBookmarks]
        if myBookmarksChannels.count == 0 {
            myBookmarksChannel = CoreDataManager.sharedInstance.createMyBookmarksChannel()
            
            self.save()
        } else {
            myBookmarksChannel = myBookmarksChannels[0]
        }
    }
    
    
    /*
     * Channel
     */
    func createChannel() -> (Channel){
        let channel = CoreDataManager.sharedInstance.createChannel()
        return channel
    }
    
    func getChannel(index: Int) -> (Channel!){
        var request = Channel.MR_requestAllSortedBy("keyword", ascending: true)
        request.predicate = NSPredicate(format: "self != %@", ModelManager.sharedInstance.myBookmarksChannel)
        
        if let channels = Channel.MR_executeFetchRequest(request) as? [Channel] {
            return channels[index]
        } else {
            return nil
        }
    }

    func getchannelById(id: NSManagedObjectID) -> (Channel!){
        let context = NSManagedObjectContext.MR_contextForCurrentThread()
        
        var error: NSError?
        let channel = context.existingObjectWithID(id, error: &error) as! Channel
        
        return channel
    }

    func getOldestChannel() -> (Channel!){
        var request = Channel.MR_requestAllSortedBy("updatedAt", ascending: true)
        request.predicate = NSPredicate(format: "self != %@", ModelManager.sharedInstance.myBookmarksChannel)
        
        if let channels = Channel.MR_executeFetchRequest(request) as? [Channel] {
            return channels[0]
        } else {
            return nil
        }
    }

    var channelCount: Int {
        get {
            var request = Channel.MR_requestAll()
            request.predicate = NSPredicate(format: "self != %@", ModelManager.sharedInstance.myBookmarksChannel)
            
            if let channels = Channel.MR_executeFetchRequest(request) as? [Channel] {
                return channels.count
            } else {
                return 0
            }
        }
    }
    
    
    /*
     * Feed Channel
     */
    func deleteFeedChannel(index: Int) {
        var channel = self.getChannel(index)
        channel.MR_deleteEntity()
    }
    
    
    /*
     * Item
     */
    var allItemCount: Int {
        get {
            var fetchRequest = Item.MR_requestAll()
            fetchRequest.predicate = NSPredicate(format: "NOT (ANY channels == %@)", ModelManager.sharedInstance.myBookmarksChannel)
            
            var items = Item.MR_executeFetchRequest(fetchRequest)
            
            return items.count
        }
    }
    
    var allUnreadItemCount: Int {
        get {
            var fetchRequest = Item.MR_requestAll()
            fetchRequest.predicate = NSPredicate(format: "NOT (ANY channels == %@) AND read = false", ModelManager.sharedInstance.myBookmarksChannel)
            
            var items = Item.MR_executeFetchRequest(fetchRequest)
            
            return items.count
        }
    }
    
    func addBookmark(url: String, bookmark: Bookmark){
        self.bookmarks[url] = bookmark
    }
    
    func getBookmark(url: String) -> (Bookmark!){
        return self.bookmarks[url]
    }

    func setCurrentUrl(url: String!){
        currentUrl = url
    }
    
    func getCurrentUrl() -> (String){
        return currentUrl
    }
    
    func updateCurrentUrl(url: String!){
        if url != currentUrl {
            currentUrl = url
            
            self.updateBookmarkCount(currentUrl)
        }
    }
    
    func getCurrentBookmarkCount() -> (Int){
        return self.currentUrlsBookmarkCount
    }
    
    
    /*
     * Setting
     */
    var entryExpireInterval: EntryExpireInterval {
        set(newValue) {
            var ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(newValue.rawValue, forKey: "EntryExpireInterval")
            ud.synchronize()
        }
        
        get {
            var ud = NSUserDefaults.standardUserDefaults()
            var interval: AnyObject? = ud.objectForKey("EntryExpireInterval")
            
            return EntryExpireInterval(rawValue: interval as! String)!
        }
    }
    
    var adsEnabled: Bool {
        set(newValue) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(newValue, forKey: "AdsEnabled")
            defaults.synchronize()
        }
        
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("AdsEnabled")
        }
    }
    
    
    /*
     * App Info
     */
    func appVersion() -> (String){
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    
    /*
     * CoreData
     */
    func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    func clearCache() {
        Item.MR_truncateAll()
        
        self.save()
    }
    
    func truncateAll() {
        Channel.MR_truncateAll()
        Item.MR_truncateAll()
        
        self.initMyBookmarks()
        
        self.save()
    }
    
    func truncateExpiredEntries() {
        var request = Item.MR_requestAll()
        var today = NSDate(timeIntervalSinceNow: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT))
        
        var interval = ModelManager.sharedInstance.entryExpireInterval
        var intervalValue = DateUtil.getExpireDateValue(interval)
        
        if intervalValue == 0 {
            Logger.log("+++++++++++++++++++++++++++++++++")
            Logger.log("Entry expiration is not activated")
            Logger.log("Setting is \(ModelManager.sharedInstance.entryExpireInterval.rawValue)")
            Logger.log("+++++++++++++++++++++++++++++++++")
            
            return
        }
        
        var expireDate = NSDate(timeInterval: NSTimeInterval(60 * 60 * 24 * intervalValue * -1), sinceDate: today)

        request.predicate = NSPredicate(format: "date < %@ AND ANY channels != %@", expireDate, ModelManager.sharedInstance.myBookmarksChannel)
        
        var items = Item.MR_executeFetchRequest(request) as! [Item]
        var deleteNum = items.count
        
        for item in items {
            item.MR_deleteEntity()
        }
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
        
        Logger.log("+++++++++++++++++++++++++++++++++")
        Logger.log("Expire Date = \(expireDate)")
        Logger.log("\(deleteNum) expired entries are deleted")
        Logger.log("+++++++++++++++++++++++++++++++++")
    }
    
    
    /*
     * Private Method
     */
    func updateBookmarkCount(url: String){
        println("getBookmarkCount", url)
        
        let bookmarkCountUrl = "http://api.b.st-hatena.com/entry.count?url=" + url
        
        Alamofire.request(.GET, bookmarkCountUrl)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["text/plain"])
            .responseString { (request, response, responseString, error) in
                
                if error != nil {
                    
                    println(request)
                    println(error?.localizedDescription)
                    
                    self.currentUrlsBookmarkCount = 0
                    self.updateBookmarkCountComplete()
                    
                } else {
                    
                    if let bookmarkNum = responseString?.toInt() {
                        self.currentUrlsBookmarkCount = bookmarkNum
                    } else {
                        self.currentUrlsBookmarkCount = 0
                    }
                    
                    self.updateBookmarkCountComplete()
                }
        }
    }
    
    private func updateBookmarkCountComplete() {
        NSNotificationCenter.defaultCenter().postNotificationName("BookmarkCountUpdated", object: nil)
    }
}
