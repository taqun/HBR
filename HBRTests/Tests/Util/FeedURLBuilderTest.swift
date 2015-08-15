//
//  FeedURLBuilderTest.swift
//  HBR
//
//  Created by taqun on 2015/07/06.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

class FeedURLBuilderTest: XCTestCase {

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
    private func createChannel() -> (Channel) {
        let channel = CoreDataManager.sharedInstance.createChannel()
        return channel
    }
    
    
    /*
     * Tests
     */
    func testBuildHotEntryFeedURL() {
        var channel = self.createChannel()
        channel.type = ChannelType.Hot
        
        channel.category = HatenaCategory.All
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/hotentry.rss")
        
        channel.category = HatenaCategory.Anime
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/hotentry/game.rss")
        
        channel.category = HatenaCategory.General
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/hotentry/general.rss")
        
        channel.category = HatenaCategory.Knowledge
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/hotentry/knowledge.rss")
        
        channel.category = HatenaCategory.Social
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/hotentry/social.rss")
    }
    
    func testBuildNewEntryFeedURL() {
        var channel = self.createChannel()
        channel.type = ChannelType.New
        
        channel.category = HatenaCategory.All
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/entrylist?sort=hot&threshold=3&mode=rss")
        
        channel.category = HatenaCategory.Economics
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/entrylist/economics?sort=hot&threshold=3&mode=rss")
        
        channel.category = HatenaCategory.It
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/entrylist/it?sort=hot&threshold=3&mode=rss")
        
        channel.category = HatenaCategory.Life
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/entrylist/life?sort=hot&threshold=3&mode=rss")
        
        channel.category = HatenaCategory.Fun
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/entrylist/fun?sort=hot&threshold=3&mode=rss")
    }
    
    func testBuildKeywordFeedURL() {
        var channel = self.createChannel()
        
        channel.type = ChannelType.Tag
        channel.keyword = "abcd"
        channel.bookmarkNum = 3
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/search/tag?safe=on&q=abcd&users=3&mode=rss")
        
        channel.type = ChannelType.Title
        channel.keyword = "1234"
        channel.bookmarkNum = 10
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/search/title?safe=on&q=1234&users=10&mode=rss")
        
        channel.type = ChannelType.Text
        channel.keyword = "テスト"
        channel.bookmarkNum = 100
        XCTAssertEqual(FeedURLBuilder.buildFeedURL(channel), "http://b.hatena.ne.jp/search/text?safe=on&q=%E3%83%86%E3%82%B9%E3%83%88&users=100&mode=rss")
    }

}
