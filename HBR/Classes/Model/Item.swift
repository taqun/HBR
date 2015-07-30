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
        self.userNum    = String(rawData["hatena:bookmarkcount"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let dateString = String(rawData["dc:date"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.date       = DateUtil.dateFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
        self.dateString = DateUtil.stringFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
        
        self.link       = String(rawData["link"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let url = NSURL(string: link)!
        self.host = url.host!
    }
    
    func parseAtomData(data: [String: String!]) {
        self.title = data["title"]!
        
        let dateValue = data["issued"]!
        let dateString = dateValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        self.date       = DateUtil.dateFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ss")
        self.dateString = DateUtil.stringFromDateString(dateString, inputFormat: "yyyy-MM-dd'T'HH:mm:ss")
        
        self.link = data["link"]!
        
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
