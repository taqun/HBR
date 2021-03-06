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
        let myBookmarksChannels = MyBookmarks.findAll()
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
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        let predicate = NSPredicate(format: "self != %@", ModelManager.sharedInstance.myBookmarksChannel)
        let sorts = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        
        let channels = Channel.findAllWithPredicateAndSort(predicate, sorts: sorts, context: context)
        
        if channels.count > index {
            return channels[index]
        } else {
            return nil
        }
    }
    
    func moveChannel(fromIndex: Int, toIndex: Int) {
        let targetChannel = self.getChannel(fromIndex)
        
        let effectedChannels: [Channel]
        if fromIndex < toIndex {
            effectedChannels = self.getChannelByRange(fromIndex, to: toIndex)
        } else {
            effectedChannels = self.getChannelByRange(toIndex, to: fromIndex)
        }
        
        targetChannel.index = toIndex
        
        
        var start: Int, end: Int, delta: Int, offset: Int
        
        if fromIndex < toIndex {
            start   = fromIndex + 1
            end     = toIndex
            delta   = -1
            offset  = fromIndex
        } else {
            start   = toIndex
            end     = fromIndex - 1
            delta   = 1
            offset  = toIndex
        }
        
        for var i = start; i <= end; i++ {
            var channel = effectedChannels[i - offset]
            channel.index = i + delta
        }
    }
    
    private func getChannelByRange(from: Int, to: Int) -> ([Channel]) {
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        let predicate = NSPredicate(format: "self != %@", ModelManager.sharedInstance.myBookmarksChannel)
        let sorts = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        
        let channels = Channel.findAllWithPredicateAndSort(predicate, sorts: sorts, context: context)
        return Array(channels[from...to])
    }

    func getChannelById(id: NSManagedObjectID) -> (Channel!){
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        
        var error: NSError?
        let channel = context.existingObjectWithID(id, error: &error) as! Channel
        
        return channel
    }

    func getOldestChannel() -> (Channel!){
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        let predicate = NSPredicate(format: "self != %@", ModelManager.sharedInstance.myBookmarksChannel)
        let sort = NSSortDescriptor(key: "updatedAt", ascending: true)
        
        let channels = Channel.findAllWithPredicateAndSort(predicate, sorts: [sort], context: context)
        
        if channels.count > 0 {
            return channels[0]
        } else {
            return nil
        }
    }

    var channelCount: Int {
        get {
            let context = CoreDataManager.sharedInstance.managedObjectContext!
            let predicate = NSPredicate(format: "self != %@", ModelManager.sharedInstance.myBookmarksChannel)
            
            let channels = Channel.findAllWithPredicate(predicate, context: context)
            
            return channels.count
        }
    }
    
    
    /*
     * Feed Channel
     */
    func deleteFeedChannel(index: Int) {
        var channel = self.getChannel(index)
        
        let predicate = NSPredicate(format: "ANY channels = %@", channel)
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        
        let items = Item.findAllWithPredicate(predicate, context: context)
        
        for item in items {
            if item.channels.count == 1 {
                item.deleteEntity()
            } else {
                var channels = item.channels
                channels.removeObject(channel)
                
                item.channels = channels
            }
        }
        
        channel.deleteEntity()
    }
    
    
    /*
     * Item
     */
    var allItemCount: Int {
        get {
            let context = CoreDataManager.sharedInstance.managedObjectContext!
            let predicate = NSPredicate(format: "NOT (ANY channels == %@)", ModelManager.sharedInstance.myBookmarksChannel)
            var items = Item.findAllWithPredicate(predicate, context: context)
            
            return items.count
        }
    }
    
    var allUnreadItemCount: Int {
        get {
            let context = CoreDataManager.sharedInstance.managedObjectContext!
            let predicate = NSPredicate(format: "NOT (ANY channels == %@) AND read = false", ModelManager.sharedInstance.myBookmarksChannel)
            var items = Item.findAllWithPredicate(predicate, context: context)

            return items.count
        }
    }
    
    
    /*
     * Bookmark
     */
    func addBookmark(url: String, bookmark: Bookmark){
        self.bookmarks[url] = bookmark
    }
    
    func getBookmark(url: String) -> (Bookmark!){
        return self.bookmarks[url]
    }
    
    private var _currentUrl: String!
    var currentUrl: String {
        set {
            if _currentUrl != newValue {
                _currentUrl = newValue
                
                self.updateBookmarkCount(_currentUrl)
            }
        }
        
        get {
            return _currentUrl
        }
    }
    
    var currentBookmarkCount: Int{
        get {
            return self.currentUrlsBookmarkCount
        }
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
        CoreDataManager.sharedInstance.saveContext()
    }
    
    func clearCache() {
        Item.truncateAll()
        
        self.save()
    }
    
    func truncateExpiredEntries() {
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

        let context = CoreDataManager.sharedInstance.managedObjectContext!
        let predicate = NSPredicate(format: "date < %@ AND ANY channels != %@", expireDate, ModelManager.sharedInstance.myBookmarksChannel)
        
        var items = Item.findAllWithPredicate(predicate, context: context)
        var deleteNum = items.count
        
        for item in items {
            item.deleteEntity()
        }
        
        CoreDataManager.sharedInstance.saveContext()
        
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
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.BOOKMARK_COUNT_UPDATED, object: nil)
    }
}
