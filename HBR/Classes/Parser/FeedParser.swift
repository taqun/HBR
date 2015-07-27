//
//  FeedParser.swift
//  HBR
//
//  Created by taqun on 2014/09/23.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class FeedParser: NSObject, NSXMLParserDelegate {
    
    var channel: Channel
    
    var parser: NSXMLParser!
    var onComplete: ((parser: FeedParser) -> Void)!
    
    var itemDatas: [[String: String!]] = []
    
    
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
        
        self.parser = parser
        self.parser.delegate = self
        self.parser.parse()
    }
    
    
    /*
     * NSXMLParserDelegate Protocol
     */
    private var isInItem = false
    private var currentElementName: String!
    private var currentFeed: [String: String!]!
    
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
            self.itemDatas.append(self.currentFeed)
            
            self.isInItem = false
            self.currentFeed = nil
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        self.onComplete(parser: self)
    }
    
}
