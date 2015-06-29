//
//  FeedParser.swift
//  HBR
//
//  Created by taqun on 2014/09/23.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

import MagicalRecord

class FeedParser: NSObject, NSXMLParserDelegate {
    
    var channel: Channel
    
    var parser: NSXMLParser!
    var onComplete: ((parser: FeedParser) -> Void)!
    
    var itemNum: Int = 0
    
    
    /*
     * Initialize
     */
    init(channel: Channel) {
        self.channel = channel
        
        super.init()
    }
    
    
    /*
     * Public Method
     */
    func parse(parser: NSXMLParser, onComplete:((parser: FeedParser) -> Void)){
        self.onComplete = onComplete
        
        itemNum = 0
        
        self.parser = parser
        self.parser.delegate = self
        self.parser.parse()
    }
    
    
    /*
     * Private Method
     */
    func createItem(data: [String: String!]) {
        var link = String(data["link"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // Exclude nicovideo for review (11.13)
        if link.rangeOfString("nicovideo.jp") != nil {
            return
        }
        
        var predicate = NSPredicate(format: "link == %@", link)
        var items = Item.MR_findAllWithPredicate(predicate, inContext: channel.managedObjectContext) as! [Item]
        
        if items.count != 0 {
            assert(items.count < 2, "A item in channel should be unique")
            
            let item = items[0]
            item.updateData(data)
            
            if let channels = item.channels.allObjects as? [Channel] {
                if !contains(channels, self.channel) {
                    MagicalRecord.saveWithBlock({ (localContext) -> Void in
                        var localChannel = self.channel.MR_inContext(localContext) as! Channel
                        var localItem = item.MR_inContext(localContext) as! Item
                        localChannel.addItems([localItem])
                    })
                }
            }
            
        } else {
            var context = channel.managedObjectContext
            var item = Item.MR_createInContext(context) as! Item
            item.parseData(data)
            currentItems.append(item)
        }
    }
    
    
    /*
    * NSXMLParserDelegate Protocol
    */
    var isInItem = false
    var currentElementName: String!
    var currentFeed: [String: String!]!
    var currentItems: [Item] = [Item]()
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        self.currentElementName = elementName
        
        if elementName == "item" {
            self.isInItem = true
            self.currentFeed = Dictionary<String, String>()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if self.isInItem {
            var currentString: String! = self.currentFeed[self.currentElementName]
            if currentString == nil {
                currentString = ""
            }
            self.currentFeed[self.currentElementName] = currentString + string!
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            self.createItem(self.currentFeed)
            
            self.isInItem = false
            self.currentFeed = nil
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        MagicalRecord.saveUsingCurrentThreadContextWithBlock({ (localContext) -> Void in
            var localChannel = self.channel.MR_inContext(localContext) as! Channel
            localChannel.addItems(self.currentItems)
        }, completion: { (success, error) -> Void in
            self.itemNum = self.currentItems.count
            self.onComplete(parser: self)
        })
        
    }
    
}
