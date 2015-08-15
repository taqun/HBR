//
//  ChannelTest.swift
//  HBR
//
//  Created by taqun on 2015/07/15.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

class ChannelTest: XCTestCase {

    override func setUp() {
        super.setUp()
        
        CoreDataManager.sharedInstance.setUpInMemoryCoreDataStack()
    }
    
    override func tearDown() {
        CoreDataManager.sharedInstance.cleanUp()
        
        super.tearDown()
    }
    
    
    /*
     * Private Method
     */
    private func createItems() -> ([Item]){
        var items: [Item] = []
        
        let data: [[String: String!]] = [
            [
                "title" : "記事タイトル1",
                "link" : "http://example.jp/foo/bar/1",
                "dc:date" : "2015-07-10T01:01:01+09:00",
                "hatena:bookmarkcount" : "123"
            ],
            [
                "title" : "記事タイトル2",
                "link" : "http://example.jp/foo/bar/1",
                "dc:date" : "2015-07-11T02:02:02+09:00",
                "hatena:bookmarkcount" : "456"
            ],
            [
                "title" : "記事タイトル3",
                "link" : "http://example.jp/foo/bar/1",
                "dc:date" : "2015-07-12T03:03:03+09:00",
                "hatena:bookmarkcount" : "789"
            ],
        ]
        
        let item1 = CoreDataManager.sharedInstance.createItem()
        item1.parseData(data[0])
        items.append(item1)
        
        let item2 = CoreDataManager.sharedInstance.createItem()
        item2.parseData(data[1])
        items.append(item2)
        
        let item3 = CoreDataManager.sharedInstance.createItem()
        item3.parseData(data[2])
        items.append(item3)
        
        return items
    }
    
    
    /*
     * Tests
     */
    func testCreateEntity() {
        let channel = CoreDataManager.sharedInstance.createChannel()
        XCTAssertNotNil(channel)
    }
    
    func testAddItems() {
        let channel = CoreDataManager.sharedInstance.createChannel()
        
        let items = self.createItems()
        channel.addItems(items)
        
        XCTAssertEqual(channel.items.count, 3)
    }
    
    func testGetUnreadItemCount() {
        let channel1 = CoreDataManager.sharedInstance.createChannel()
        
        let items1 = self.createItems()
        channel1.addItems(items1)
        
        XCTAssertEqual(channel1.unreadItemCount, 3)
        
        let channel2 = CoreDataManager.sharedInstance.createChannel()
        
        let items2 = self.createItems()
        items2[0].read = true
        items2[1].read = true
        
        channel2.addItems(items2)
        
        XCTAssertEqual(channel2.unreadItemCount, 1)
    }
    
    func testMarkAsReadAllItems() {
        let channel = CoreDataManager.sharedInstance.createChannel()
        let items = self.createItems()
        channel.addItems(items)
        XCTAssertEqual(channel.unreadItemCount, 3)
        
        channel.markAsReadAllItems()
        XCTAssertEqual(channel.unreadItemCount, 0)
    }
    
    func testChannelTitle() {
        let channel = CoreDataManager.sharedInstance.createChannel()
        
        channel.type = ChannelType.Hot
        channel.category = HatenaCategory.All
        XCTAssertEqual(channel.title, "人気エントリー (総合)")
        
        channel.category = HatenaCategory.Economics
        XCTAssertEqual(channel.title, "人気エントリー (政治と経済)")
        
        channel.type = ChannelType.New
        channel.category = HatenaCategory.Fun
        XCTAssertEqual(channel.title, "新着エントリー (おもしろ)")
        
        channel.category = HatenaCategory.Entertainment
        XCTAssertEqual(channel.title, "新着エントリー (エンタメ)")
    }
    
    func testChannelShortTitle() {
        let channel = CoreDataManager.sharedInstance.createChannel()
        
        channel.type = ChannelType.Hot
        channel.category = HatenaCategory.All
        XCTAssertEqual(channel.shortTitle, "人気 (総合)")
        
        channel.category = HatenaCategory.Economics
        XCTAssertEqual(channel.shortTitle, "人気 (政治と経済)")
        
        channel.type = ChannelType.New
        channel.category = HatenaCategory.Fun
        XCTAssertEqual(channel.shortTitle, "新着 (おもしろ)")
        
        channel.category = HatenaCategory.Entertainment
        XCTAssertEqual(channel.shortTitle, "新着 (エンタメ)")
    }

}
