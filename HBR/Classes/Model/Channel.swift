//
//  Channel.swift
//  HBR
//
//  Created by taqun on 2014/10/13.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

enum ChannelType: String {
    case Hot    = "hot"
    case New    = "new"
    case Tag    = "tag"
    case Title  = "title"
    case Text   = "text"
    case Mine   = "mine"
}

@objc(Channel)
class Channel: NSManagedObject {
    
    @NSManaged private var keyword: String
    @NSManaged var bookmarkNum: NSNumber
    @NSManaged var updatedAt: NSDate
    
    @NSManaged private var typeValue: String
    @NSManaged private var categoryValue: String
    
    @NSManaged var items: NSMutableSet
    
    
    /*
     * Public Method
     */
    func initKeyword(keyword: String) {
        self.keyword = keyword
    }
    
    func addItems(newItems: [Item]) {
        var set = self.mutableSetValueForKey("items")
        
        for item: Item in newItems {
            set.addObject(item)
        }
        
        self.updatedAt = NSDate()
    }
    
    func getLatestItemDate() -> (NSDate) {
        func feedSort(f1: Item, f2: Item) -> (Bool) {
            return f1.date.timeIntervalSinceNow > f2.date.timeIntervalSinceNow
        }
        
        var items = self.items.allObjects as! [Item]
        items = sorted(items, feedSort)
        
        return items[0].date
    }
    
    func getUnreaditemCount() -> (Int) {
        var fetchRequest = Item.MR_requestAll()
        fetchRequest.predicate = NSPredicate(format: "ANY channels == %@ AND read = false", self)
        
        var items = Item.MR_executeFetchRequest(fetchRequest)
        
        return items.count
    }
    
    func markAsReadAllItems() {
        var items = self.items.allObjects as! [Item]
        
        for item: Item in items {
            item.read = true
        }
    }
    
    func getFeedURL() -> (String) {
        switch self.type {
            case ChannelType.Hot:
                return FeedURLBuilder.getHotEntryFeedURL(self.category)
            
            case ChannelType.New:
                return FeedURLBuilder.getNewEntryFeedURL(self.category)
            
            default:
                let escapedKeyword = keyword.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                let typeString = self.typeValue
                
                return "http://b.hatena.ne.jp/search/\(typeString)?safe=on&q=\(escapedKeyword)&users=\(bookmarkNum)&mode=rss"
        }
    }
    
    
    /*
     * Getter, Setter
     */
    var title: String {
        get {
            switch self.type {
                case .Hot:
                    return "人気エントリー (\(self.categoryValue))"
                
                case .New:
                    return "新着エントリー (\(self.categoryValue))"
                
                case .Mine:
                    return "マイブックマーク"
                
                default:
                    return self.keyword
            }
        }
    }
    
    var shortTitle: String {
        get {
            switch self.type {
                case .Hot:
                    return "人気 (\(self.categoryValue))"
                
                case .New:
                    return "新着 (\(self.categoryValue))"
                
                default:
                    return self.keyword
                }
        }
    }
    
    var type: ChannelType {
        get {
            return ChannelType(rawValue: self.typeValue)!
        }
        
        set {
            self.typeValue = newValue.rawValue
        }
    }
    
    var category: HatenaCategory {
        get {
            return HatenaCategory(rawValue: self.categoryValue)!
        }
        
        set {
            self.categoryValue = newValue.rawValue
        }
    }

}
