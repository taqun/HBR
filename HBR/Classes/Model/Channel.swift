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


class Channel: NSManagedObject {
    
    @NSManaged var keyword: String
    @NSManaged var bookmarkNum: NSNumber
    @NSManaged var updatedAt: NSDate
    
    @NSManaged private var typeValue: String
    @NSManaged private var categoryValue: String
    
    @NSManaged var items: NSMutableSet
    
    
    /*
     * Static Method
     */
    static func findAllWithPredicate(predicate: NSPredicate, context: NSManagedObjectContext) -> ([Channel]) {
        var request = NSFetchRequest()
        request.entity = CoreDataManager.sharedInstance.getEntityByName("Channel", context: context)
        request.predicate = predicate
        
        var error: NSError? = nil
        
        if var results = context.executeFetchRequest(request, error: &error) as? [Channel] {
            return results
        } else {
            return []
        }
    }
    
    static func findAllWithPredicateAndSort(predicate: NSPredicate, sorts:[NSSortDescriptor], context: NSManagedObjectContext) -> ([Channel]) {
        var request = NSFetchRequest()
        request.entity = CoreDataManager.sharedInstance.getEntityByName("Channel", context: context)
        request.predicate = predicate
        request.sortDescriptors = sorts
        
        var error: NSError? = nil
        
        if var results = context.executeFetchRequest(request, error: &error) as? [Channel] {
            return results
        } else {
            return []
        }
    }
    
    static func truncateAll() {
        
    }
    
    
    
    
    /*
     * Public Method
     */
    func addItems(newItems: [Item]) {
        var set = self.mutableSetValueForKey("items")
        
        for item: Item in newItems {
            set.addObject(item)
        }
        
        self.updatedAt = NSDate()
    }
    
    func markAsReadAllItems() {
        var items = self.items.allObjects as! [Item]
        
        for item: Item in items {
            item.read = true
        }
    }
    
    
    func inContext(context: NSManagedObjectContext) -> (Channel) {
        return self
    }
    
    func deleteEntity() {
        
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
    
    var feedURL: String {
        get {
            return FeedURLBuilder.buildFeedURL(self)
        }
    }
    
    var unreadItemCount: Int {
        get {
            let predicate = NSPredicate(format: "ANY channels == %@ AND read = false", self)
            let context = CoreDataManager.sharedInstance.managedObjectContext!
            
            let items = Item.findAllWithPredicate(predicate, context: context)
            
            return items.count
        }
    }

}
