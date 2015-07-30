//
//  AtomFeedParser.swift
//  HBR
//
//  Created by taqun on 2015/07/30.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

import AEXML

class AtomFeedParser: NSObject {
    
    var itemDatas: [[String: String!]] = []
    
    /*
     * Public Method
     */
    func parse(data: NSData, onComplete:((parser: AtomFeedParser) -> Void)) -> (Void) {
        
        var newItems = [Item]()
        var error: NSError?
        
        if let xml = AEXMLDocument(xmlData: data, error: &error) {
            if let entries = xml.root["entry"].all {
                for entry in entries {
                    let children = entry.children
                    var itemData: [String: String!] = [:]
                    
                    for child in children {
                        itemData[child.name] = child.value
                    }
                    
                    itemData["link"] = self.getHrefLinkFromAtomData(entry)
                    
                    itemDatas.append(itemData)
                }
            }
        }
        
        onComplete(parser: self)
    }
    
    
    /*
     * Private Method
     */
    private func getHrefLinkFromAtomData(entry: AEXMLElement) -> (String) {
        var link = ""
        
        if let links = entry["link"].all {
            for linkElement in links {
                if let rel = linkElement.attributes["rel"] as? String {
                    if rel == "related" {
                        if let linkValue = linkElement.attributes["href"] as? String {
                            link = linkValue
                        }
                    }
                }
            }
        }
        
        return link
    }
    
}
