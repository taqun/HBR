//
//  ItemTest.swift
//  HBR
//
//  Created by taqun on 2015/07/14.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

import AEXML

class ItemTest: XCTestCase {

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
    func testCreateEntity() {
        let item = CoreDataManager.sharedInstance.createItem()
        
        XCTAssertNotNil(item)
    }
    
    func testParseData() {
        let data: [String: String!] = [
            "title" : "記事タイトル",
            "link" : "http://example.jp/foo/bar",
            "dc:date" : "2015-07-14T07:31:29+09:00",
            "hatena:bookmarkcount" : "12345"
        ]
        
        let item = CoreDataManager.sharedInstance.createItem()
        item.parseData(data)
        
        XCTAssertEqual(item.title, "記事タイトル")
        XCTAssertEqual(item.link, "http://example.jp/foo/bar")
        XCTAssertEqual(item.host, "example.jp")
        XCTAssertEqual(item.userNum, "12345")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.dateFromString("2015-07-14T07:31:29+09:00") {
            XCTAssertEqual(item.date, date)
        } else {
            XCTFail("Failed to parse item date")
        }
    }
    
    func testParseAtomData() {
        let data: [String: String!] = [
            "title" : "記事タイトル",
            "link" : "http://example.jp/foo/bar",
            "issued" : "2015-04-21T23:56:20"
        ]
        
        let item = CoreDataManager.sharedInstance.createItem()
        item.parseAtomData(data)
        
        XCTAssertEqual(item.title, "記事タイトル")
        XCTAssertEqual(item.link, "http://example.jp/foo/bar")
        XCTAssertEqual(item.host, "example.jp")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.dateFromString("2015-04-21T23:56:20") {
            XCTAssertEqual(item.date, date)
        } else {
            XCTFail("Failed to parse item date")
        }
    }
    
    func testUpdateData() {
        let data: [String: String!] = [
            "title" : "変更前タイトル",
            "description" : "記事デスクリプション",
            "link" : "http://example.jp/foo/bar",
            "dc:date" : "2015-07-14T07:31:29+09:00",
            "hatena:bookmarkcount" : "12345"
        ]
        
        let item = CoreDataManager.sharedInstance.createItem()
        item.parseData(data)
        
        XCTAssertEqual(item.title, "変更前タイトル")
        XCTAssertEqual(item.userNum, "12345")
        
        let updateData: [String: String!] = [
            "title" : "変更後タイトル",
            "hatena:bookmarkcount" : "98765"
        ]
        
        item.updateData(updateData)
        
        XCTAssertEqual(item.title, "変更後タイトル")
        XCTAssertEqual(item.userNum, "98765")
    }
    
    func testTruncateAll() {
        let item1 = CoreDataManager.sharedInstance.createItem()
        let item2 = CoreDataManager.sharedInstance.createItem()
        let item3 = CoreDataManager.sharedInstance.createItem()
        
        XCTAssertEqual(ModelManager.sharedInstance.allItemCount, 3)
        
        Item.truncateAll()
        
        XCTAssertEqual(ModelManager.sharedInstance.allItemCount, 0)
    }

}
