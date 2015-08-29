//
//  ModelManagerTest.swift
//  HBR
//
//  Created by taqun on 2015/07/18.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

class ModelManagerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        
        CoreDataManager.sharedInstance.setUpInMemoryCoreDataStack()
    }
    
    override func tearDown() {
        CoreDataManager.sharedInstance.cleanUp()
        
        super.tearDown()
    }
    
    
    /*
     * Tests
     */
    func testCreateInstance() {
        let model = ModelManager.sharedInstance
        XCTAssertNotNil(model)
        
        let model2 = ModelManager.sharedInstance
        XCTAssertEqual(model, model2)
        
        XCTAssertNotNil(model.myBookmarksChannel)
    }
    
    
    // Channel
    
    func testCreateChannel() {
        let channel = ModelManager.sharedInstance.createChannel()
        XCTAssertNotNil(channel)
    }
    
    func testGetChannel() {
        let channel1 = ModelManager.sharedInstance.createChannel()
        channel1.index = 1
        let channel2 = ModelManager.sharedInstance.createChannel()
        channel2.index = 2
        let channel3 = ModelManager.sharedInstance.createChannel()
        channel3.index = 0
        
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel3)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(1), channel1)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(2), channel2)
    }
    
    func testMoveChannel() {
        let channel0 = ModelManager.sharedInstance.createChannel()
        channel0.keyword = "channel0"
        channel0.index = 0
        let channel1 = ModelManager.sharedInstance.createChannel()
        channel1.keyword = "channel1"
        channel1.index = 1
        let channel2 = ModelManager.sharedInstance.createChannel()
        channel2.keyword = "channel2"
        channel2.index = 2
        let channel3 = ModelManager.sharedInstance.createChannel()
        channel3.keyword = "channel3"
        channel3.index = 3
        
        // 0, 1, 2, 3 => 3, 0, 1, 2
        ModelManager.sharedInstance.moveChannel(3, toIndex: 0)
        
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel3)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(1), channel0)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(2), channel1)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(3), channel2)
        
        // 3, 0, 1, 2 => 0, 1, 2, 3
        ModelManager.sharedInstance.moveChannel(0, toIndex: 3)
        
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel0)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(1), channel1)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(2), channel2)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(3), channel3)
        
        // 0, 1, 2, 3 => 0, 1, 3, 2
        ModelManager.sharedInstance.moveChannel(3, toIndex: 2)
        
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel0)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(1), channel1)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(2), channel3)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(3), channel2)
        
        // 0, 1, 3, 2 => 0, 1, 2, 3
        ModelManager.sharedInstance.moveChannel(2, toIndex: 3)
        
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel0)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(1), channel1)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(2), channel2)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(3), channel3)
    }
    
    func testChannelCount() {
        XCTAssertNotNil(ModelManager.sharedInstance.myBookmarksChannel)
        
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 0)
        
        ModelManager.sharedInstance.createChannel()
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 1)
        
        ModelManager.sharedInstance.createChannel()
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 2)
    }
    
    func testDeleteFeedChannel() {
        let channel1 = ModelManager.sharedInstance.createChannel()
        channel1.index = 3
        let channel2 = ModelManager.sharedInstance.createChannel()
        channel2.index = 2
        let channel3 = ModelManager.sharedInstance.createChannel()
        channel3.index = 1
        
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 3)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel3)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(2), channel1)
        
        ModelManager.sharedInstance.deleteFeedChannel(1)
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 2)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel3)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(1), channel1)
    }
    
    func testDeleteFeedChannelWithItems() {
        let channel = ModelManager.sharedInstance.createChannel()
        
        let item1 = CoreDataManager.sharedInstance.createItem()
        let item2 = CoreDataManager.sharedInstance.createItem()
        channel.addItems([item1, item2])
        
        let otherItem = CoreDataManager.sharedInstance.createItem()
        
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 1)
        XCTAssertEqual(channel.items.count, 2)
        
        let predicate = NSPredicate(format: "1 = 1")
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        XCTAssertEqual(Item.findAllWithPredicate(predicate, context: context).count, 3)
        
        
        ModelManager.sharedInstance.deleteFeedChannel(0)
        
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 0)
        XCTAssertEqual(Item.findAllWithPredicate(predicate, context: context).count, 1)
    }
    
    func testDeleteFeedChannelWithItemIsHoldByMultipleChannels() {
        let channel1 = ModelManager.sharedInstance.createChannel()
        channel1.keyword = "channel2"
        channel1.index = 1
        let channel2 = ModelManager.sharedInstance.createChannel()
        channel2.keyword = "channel1"
        channel2.index = 0
        
        let item = CoreDataManager.sharedInstance.createItem()
        
        channel1.addItems([item])
        channel2.addItems([item])
        
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 2)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel2)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(1), channel1)
        XCTAssertEqual(channel1.items.count, 1)
        XCTAssertEqual(channel2.items.count, 1)
        XCTAssertEqual(item.channels.count, 2)
        
        let predicate = NSPredicate(format: "1 = 1")
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        XCTAssertEqual(Item.findAllWithPredicate(predicate, context: context).count, 1)
        
        
        ModelManager.sharedInstance.deleteFeedChannel(0)
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 1)
        XCTAssertEqual(ModelManager.sharedInstance.getChannel(0), channel1)
        XCTAssertEqual(channel1.items.count, 1)
        XCTAssertEqual(item.channels.count, 1)
        XCTAssertEqual(item.channels.allObjects[0] as! Channel, channel1)

        XCTAssertEqual(Item.findAllWithPredicate(predicate, context: context).count, 1)
    }
    
    
    // Item
    
    func testAllItemCount() {
        XCTAssertEqual(ModelManager.sharedInstance.allItemCount, 0)
        
        CoreDataManager.sharedInstance.createItem()
        XCTAssertEqual(ModelManager.sharedInstance.allItemCount, 1)
        
        CoreDataManager.sharedInstance.createItem()
        CoreDataManager.sharedInstance.createItem()
        XCTAssertEqual(ModelManager.sharedInstance.allItemCount, 3)
    }
    
    func testAllUnreadItemCount() {
        XCTAssertEqual(ModelManager.sharedInstance.allUnreadItemCount, 0)
        
        CoreDataManager.sharedInstance.createItem()
        XCTAssertEqual(ModelManager.sharedInstance.allUnreadItemCount, 1)
        
        let item = CoreDataManager.sharedInstance.createItem()
        item.read = true
        XCTAssertEqual(ModelManager.sharedInstance.allUnreadItemCount, 1)
        
        CoreDataManager.sharedInstance.createItem()
        let item2 = CoreDataManager.sharedInstance.createItem()
        item2.read = true
        CoreDataManager.sharedInstance.createItem()
        XCTAssertEqual(ModelManager.sharedInstance.allUnreadItemCount, 3)
    }
    
    
    // Bookmark
    
    func testAddBookmark() {
        let data1 = [
            "bookmarks": [
                [
                    "user" : "user_name1",
                    "timestamp" : "2015/07/15 15:47:36",
                    "comment" : ""
                ],
                [
                    "user" : "user_name2",
                    "timestamp" : "2015/07/16 15:47:36",
                    "comment" : "コメント"
                ]
            ]
        ]
        let bookmark1 = Bookmark(data: data1)
        ModelManager.sharedInstance.addBookmark("http://example.jp/foo/bar/1", bookmark: bookmark1)
        
        let data2 = [
            "bookmarks": [
                [
                    "user" : "user_name3",
                    "timestamp" : "2015/07/15 15:47:36",
                    "comment" : "コメント2"
                ],
                [
                    "user" : "user_name2",
                    "timestamp" : "2015/07/16 15:47:36",
                    "comment" : "コメント3"
                ]
            ]
        ]
        let bookmark2 = Bookmark(data: data2)
        ModelManager.sharedInstance.addBookmark("http://example.jp/foo/bar/2", bookmark: bookmark2)
        
        XCTAssertEqual(ModelManager.sharedInstance.getBookmark("http://example.jp/foo/bar/1"), bookmark1)
        XCTAssertEqual(ModelManager.sharedInstance.getBookmark("http://example.jp/foo/bar/2"), bookmark2)
        XCTAssertNotEqual(ModelManager.sharedInstance.getBookmark("http://example.jp/foo/bar/1"), bookmark2)
    }
    
    func testCurrentURL() {
        ModelManager.sharedInstance.currentUrl = "http://example.jp/foo/bar"
        XCTAssertEqual(ModelManager.sharedInstance.currentUrl, "http://example.jp/foo/bar")
    }
    
    
    // App Settings
    
    func testAdsEnabled() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("AdsEnabled")
        
        XCTAssertEqual(ModelManager.sharedInstance.adsEnabled, true)
        
        ModelManager.sharedInstance.adsEnabled = false
        XCTAssertEqual(ModelManager.sharedInstance.adsEnabled, false)
    }
    
    func testEntryExpireInterval() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("EntryExpireInterval")
        
        XCTAssertEqual(ModelManager.sharedInstance.entryExpireInterval, EntryExpireInterval.OneWeek)
        
        ModelManager.sharedInstance.entryExpireInterval = EntryExpireInterval.OneMonth
        XCTAssertEqual(ModelManager.sharedInstance.entryExpireInterval, EntryExpireInterval.OneMonth)
    }

}
