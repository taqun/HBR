//
//  BookmarkItemTest.swift
//  HBR
//
//  Created by taqun on 2015/07/19.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

class BookmarkItemTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    /*
     * Tests
     */
    func testCreateInstance() {
        let data = [
            "user" : "user_name",
            "timestamp" : "2015/07/18 15:47:36",
            "comment" : "コメント"
        ]
        
        let item = BookmarkItem(data: data)
        XCTAssertEqual(item.user, "user_name")
        XCTAssertEqual(item.comment, "コメント")
        XCTAssertEqual(item.iconUrl, "http://cdn1.www.st-hatena.com/users/us/user_name/profile.gif")
        
        XCTAssertEqual(item.dateString, "2015/07/18 15:47")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        if let date = formatter.dateFromString("2015/07/18 15:47:36") {
            XCTAssertEqual(item.date, date)
        } else {
            XCTFail("Failed to parse item date")
        }
    }
    
    func testCreateInstanceWithoutComment() {
        let data = [
            "user" : "user_name",
            "timestamp" : "2015/07/18 15:47:36",
            "comment": ""
        ]
        
        let item = BookmarkItem(data: data)
        XCTAssertNotNil(item.comment)
        XCTAssertEqual(item.comment, "")
    }

}
