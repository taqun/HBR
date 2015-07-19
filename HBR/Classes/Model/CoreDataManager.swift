//
//  CoreDataManager.swift
//  HBR
//
//  Created by taqun on 2015/07/18.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
   
    static var sharedInstance: CoreDataManager = CoreDataManager()
    
    func createChannel() -> (Channel) {
        let isInTests = (NSClassFromString("XCTest") != nil)
        if isInTests {
            let context = NSManagedObjectContext.MR_defaultContext()
            let entity = NSEntityDescription.entityForName("Channel", inManagedObjectContext: context)!
            let channel = Channel(entity: entity, insertIntoManagedObjectContext: context)
            
            return channel
        } else {
            let channel = Channel.MR_createEntity() as! Channel
            
            return channel
        }
    }
    
    func createMyBookmarksChannel() -> (MyBookmarks) {
        let isInTests = (NSClassFromString("XCTest") != nil)
        if isInTests {
            let context = NSManagedObjectContext.MR_defaultContext()
            let entity = NSEntityDescription.entityForName("MyBookmarks", inManagedObjectContext: context)!
            let myBookmarksChannel = MyBookmarks(entity: entity, insertIntoManagedObjectContext: context)
            
            return myBookmarksChannel
        } else {
            let myBookmarksChannel = MyBookmarks.MR_createEntity() as! MyBookmarks
            myBookmarksChannel.type = .Mine
            
            return myBookmarksChannel
        }
    }
    
    func createItem() -> (Item) {
        let isInTests = (NSClassFromString("XCTest") != nil)
        if isInTests {
            let context = NSManagedObjectContext.MR_defaultContext()
            let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: context)!
            let item = Item(entity: entity, insertIntoManagedObjectContext: context)
            
            return item
        } else {
            let item = Item.MR_createEntity() as! Item
            
            return item
        }
    }
}
