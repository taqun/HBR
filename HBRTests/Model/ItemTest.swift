//
//  ItemTest.swift
//  HBR
//
//  Created by taqun on 2015/07/14.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import XCTest

import MagicalRecord
import AEXML

class ItemTest: XCTestCase {

    override func setUp() {
        super.setUp()
        
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }
    
    override func tearDown() {
        MagicalRecord.cleanUp()
        
        super.tearDown()
    }
    
    
    /*
     * Private Method
     */
    private func createItem() -> (Item) {
        let context = NSManagedObjectContext.MR_defaultContext()
        let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: context)!
        let item = Item(entity: entity, insertIntoManagedObjectContext: context)
        
        return item
    }
    
    
    /*
     * Tests
     */
    func testCreateEntity() {
        let item = self.createItem()
        
        XCTAssertNotNil(item)
    }
    
    func testParseData() {
        let data: [String: String!] = [
            "title" : "記事タイトル",
            "description" : "記事デスクリプション",
            "link" : "http://example.jp/foo/bar",
            "dc:date" : "2015-07-14T07:31:29+09:00",
            "hatena:bookmarkcount" : "12345"
        ]
        
        let item = self.createItem()
        item.parseData(data)
        
        XCTAssertEqual(item.title, "記事タイトル")
        XCTAssertEqual(item.desc, "記事デスクリプション")
        XCTAssertEqual(item.link, "http://example.jp/foo/bar")
        XCTAssertEqual(item.userNum, "12345")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.dateFromString("2015-07-14T07:31:29+09:00") {
            XCTAssertEqual(item.date, date)
        } else {
            XCTFail("Failed to parse item date")
        }
    }
    
    func testParseXMLData() {
        let xml = AEXMLDocument()
        let entry = xml.addChild(name: "entry")
        entry.addChild(name: "title", value: "記事タイトル")
        entry.addChild(name: "link", value: nil, attributes: ["type" : "text/html", "rel" : "related", "href" : "http://example.jp/foo/bar"])
        entry.addChild(name: "issued", value: "2015-04-21T23:56:20")
        
        let item = self.createItem()
        item.parseXMLData(entry)
        
        XCTAssertEqual(item.title, "記事タイトル")
        XCTAssertEqual(item.link, "http://example.jp/foo/bar")
        
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
        
        let item = self.createItem()
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

}
