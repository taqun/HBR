//
//  BookmarkTest.swift
//  HBR
//
//  Created by taqun on 2015/07/19.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

class BookmarkTest: XCTestCase {

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
        let data = [
            "bookmarks": [
                [
                    "user" : "user_name1",
                    "timestamp" : "2015/07/15 15:47:36",
                    "comment" : ""
                ],
                [
                    "user" : "user_name2",
                    "timestamp" : "2015/07/16 15:47:36",
                    "comment" : "コメント1"
                ],
                [
                    "user" : "user_name3",
                    "timestamp" : "2015/07/17 15:47:36",
                    "comment" : "コメント2"
                ]
            ]
        ]
        
        let bookmark = Bookmark(data: data)
        XCTAssertEqual(bookmark.items.count, 3)
    }
    
    func testCommentItem() {
        let data = [
            "bookmarks": [
                [
                    "user" : "user_name1",
                    "timestamp" : "2015/07/15 15:47:36",
                    "comment" : ""
                ],
                [
                    "user" : "user_name2",
                    "timestamp" : "2015/07/16 15:47:36",
                    "comment" : "コメント2"
                ],
                [
                    "user" : "user_name3",
                    "timestamp" : "2015/07/17 15:47:36",
                    "comment" : "コメント3"
                ],
                [
                    "user" : "user_name4",
                    "timestamp" : "2015/07/15 15:47:36",
                    "comment" : "コメント1"
                ],
            ]
        ]
        
        let bookmark = Bookmark(data: data)
        XCTAssertEqual(bookmark.items.count, 4)
        XCTAssertEqual(bookmark.commentItemCount, 3)
        
        let item1 = bookmark.getCommentItem(0)
        XCTAssertEqual(item1.user, "user_name3")
        XCTAssertEqual(item1.comment, "コメント3")
        
        let item2 = bookmark.getCommentItem(1)
        XCTAssertEqual(item2.user, "user_name2")
        XCTAssertEqual(item2.comment, "コメント2")
        
        let item3 = bookmark.getCommentItem(2)
        XCTAssertEqual(item3.user, "user_name4")
        XCTAssertEqual(item3.comment, "コメント1")
    }

}
