//
//  Item.swift
//  HBR
//
//  Created by taqun on 2014/10/13.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

import AEXML

@objc(Item)
class Item: NSManagedObject {
    
    @NSManaged var rawData: NSData
    @NSManaged var title: String
    @NSManaged var desc: String
    @NSManaged var userNum: String!
    @NSManaged var date: NSDate
    @NSManaged var dateString: String
    @NSManaged var link: String
    @NSManaged var host: String
    @NSManaged var read: NSNumber
    
    @NSManaged var channels: NSMutableSet
    
    
    /*
     * Public Method
     */
    func parseData(data: [String: String!]) {
        let rawData = data
        
        self.title      = String(rawData["title"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.desc       = String(rawData["description"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.userNum    = String(rawData["hatena:bookmarkcount"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // 2014-09-13T18:20:42+09:00
        let dateString = String(rawData["dc:date"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.date       = DateUtil.dateFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
        self.dateString = DateUtil.stringFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
        
        self.link       = String(rawData["link"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let url = NSURL(string: link)!
        self.host = url.host!
    }
    
    func parseXMLData(entry: AEXMLElement) {
        if let title = entry["title"].value {
            self.title = title
        }
        
        // 2015-05-05T23:36:58"
        if let dateValue = entry["issued"].value {
            let dateString = dateValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.date       = DateUtil.dateFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ss")
            self.dateString = DateUtil.stringFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ss")
        }
        
        self.link = FeedParserUtil.getHrefLinkFromAtomData(entry)
        
        let url = NSURL(string: self.link)!
        self.host = url.host!
    }
    
    func updateData(data: [String: String!]) {
        let rawData = data
        
        if let titleData = rawData["title"] {
            let title = String(titleData).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if self.title != title {
                self.title = title
            }
        }
        
        if let countValue = rawData["hatena:bookmarkcount"] {
            let userNum = String(countValue).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if self.userNum == nil || self.userNum.toInt() < userNum.toInt() {
                self.userNum = userNum
            }
        }
    }
}
