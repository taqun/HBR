//
//  AtomFeedParserTest.swift
//  HBR
//
//  Created by taqun on 2015/07/30.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

class AtomFeedParserTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    /*
     * Tests
     */
    func testCreateInstanace() {
        let parser = AtomFeedParser()
        XCTAssertNotNil(parser)
    }
    
    private var callbackException: XCTestExpectation!
    
    func testParse() {
        let parser = AtomFeedParser()
        
        let path = NSBundle(forClass: self.dynamicType).pathForResource("atom", ofType: "xml")
        let data = NSData(contentsOfFile: path!)!
        
        callbackException = self.expectationWithDescription("Callback method is called")
        
        parser.parse(data, onComplete: self.testComplete)
        
        self.waitForExpectationsWithTimeout(0.5, handler: { (error) -> Void in
            
        })
    }
    
    private func testComplete(parser: AtomFeedParser) {
        XCTAssertEqual(parser.itemDatas.count, 3)
        
        let item1 = parser.itemDatas[0]
        let title1 = item1["title"]!
        XCTAssertEqual(title1, "エントリー１")
        
        let item2 = parser.itemDatas[1]
        let link2 = item2["link"]!
        XCTAssertEqual(link2, "http://example.jp/bar")
        
        let item3 = parser.itemDatas[2]
        let issued3 = item3["issued"]!
        XCTAssertEqual(issued3, "2015-06-26T09:36:06")
        
        callbackException.fulfill()
    }

}
