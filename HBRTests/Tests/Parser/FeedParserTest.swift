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
        let data = NSData(contentsOfFile: path!)
        callbackException = self.expectationWithDescription("Callback method is called")
        
        let xmlParser = NSXMLParser(data: data!)
        parser.parse(xmlParser, onComplete: self.parseComplete)
        
        self.waitForExpectationsWithTimeout(0.5, handler: { (error) -> Void in
            
        })
    }
    
    func parseComplete(parser: FeedParser) {
        XCTAssertEqual(channel, parser.channel)
        XCTAssertEqual(parser.itemDatas.count, 3)

        callbackException.fulfill()
    }

}
