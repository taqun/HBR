//
//  FeedParser.swift
//  HBR
//
//  Created by taqun on 2014/09/23.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

import AEXML

class FeedParser: NSObject {
    
    var channel: Channel
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
    func parse(data: NSData, onComplete:((parser: FeedParser) -> Void)){
        var error: NSError?
        
        if let xml = AEXMLDocument(xmlData: data, error: &error) {
            if let items = xml.root["item"].all {
                for item in items {
                    let children = item.children
                    var itemData: [String: String!] = [:]
                    
                    for child in children{
                        itemData[child.name] = child.value
                    }
                    
                    itemDatas.append(itemData)
                }
            }
        }
        
        onComplete(parser: self)
    }
}
