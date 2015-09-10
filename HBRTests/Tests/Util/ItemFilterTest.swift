//
//  ItemFilterTest.swift
//  HBR
//
//  Created by ysap04 on 2015/09/10.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

class ItemFilterTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    // MARK: - Tests
    
    func testIsValid() {
        var itemData1: [String: String!] = [
            "title": "hoge",
            "link": "fuga"
        ]
        var itemData2: [String: String!] = [
            "title": "2chhoge",
            "link": "fuga"
        ]
        var itemData3: [String: String!] = [
            "title": "hoge",
            "link": "2chfuga"
        ]
        var itemData4: [String: String!] = [
            "title": "2chhoge",
            "link": "2chfuga"
        ]
        
        XCTAssertTrue(ItemFilter.isValid(itemData1))
        XCTAssertFalse(ItemFilter.isValid(itemData2))
        XCTAssertFalse(ItemFilter.isValid(itemData3))
        XCTAssertFalse(ItemFilter.isValid(itemData4))
    }

}
