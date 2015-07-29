//
//  FeedParserTest.swift
//  HBR
//
//  Created by taqun on 2015/07/26.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

import MagicalRecord

class FeedParserTest: XCTestCase {

    override func setUp() {
        super.setUp()
        
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }
    
    override func tearDown() {
        MagicalRecord.cleanUp()
        
        super.tearDown()
    }
    
    
    /*
     * Test
     */
    func testCreateInstance() {
        let channel = CoreDataManager.sharedInstance.createChannel()
        let parser = FeedParser(channel: channel)
        XCTAssertNotNil(parser)
    }
    
    private var channel: Channel!
    private var callbackException: XCTestExpectation!
    
    func testParse() {
        channel = CoreDataManager.sharedInstance.createChannel()
        let parser = FeedParser(channel: channel)
        
        let path = NSBundle(forClass: self.dynamicType).pathForResource("channel", ofType: "xml")
        let data = NSData(contentsOfFile: path!)!
        callbackException = self.expectationWithDescription("Callback method is called")
        
        parser.parse(data, onComplete: self.parseComplete)
        
        self.waitForExpectationsWithTimeout(0.5, handler: { (error) -> Void in
            
        })
    }
    
    func parseComplete(parser: FeedParser) {
        XCTAssertEqual(channel, parser.channel)
        XCTAssertEqual(parser.itemDatas.count, 3)
        
        let item1 = parser.itemDatas[0]
        let link1 = String(item1["link"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        XCTAssertEqual(link1, "http://example.jp/foo")
        
        let item2 = parser.itemDatas[1]
        let title2 = String(item2["title"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        XCTAssertEqual(title2, "記事2")
        
        let item3 = parser.itemDatas[2]
        let date3 = String(item3["dc:date"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        XCTAssertEqual(date3, "2015-07-25T12:15:50+09:00")

        callbackException.fulfill()
    }

}
