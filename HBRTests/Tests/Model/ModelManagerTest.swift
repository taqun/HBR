//
//  ModelManagerTest.swift
//  HBR
//
//  Created by taqun on 2015/07/18.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

import MagicalRecord

class ModelManagerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }
    
    override func tearDown() {
        MagicalRecord.cleanUp()
        
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
    
    func testChannelCount() {
        XCTAssertNotNil(ModelManager.sharedInstance.myBookmarksChannel)
        
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 0)
        
        // Following tests are not working because of swift namespace issue
        /*
        ModelManager.sharedInstance.createChannel()
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 1)
        
        ModelManager.sharedInstance.createChannel()
        XCTAssertEqual(ModelManager.sharedInstance.channelCount, 2)
        */
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
        // TODO: Refactor
        ModelManager.sharedInstance.setCurrentUrl("http://example.jp/foo/bar")
        XCTAssertEqual(ModelManager.sharedInstance.getCurrentUrl(), "http://example.jp/foo/bar")
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
