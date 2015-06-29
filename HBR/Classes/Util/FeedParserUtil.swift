//
//  FeedParserUtil.swift
//  HBR
//
//  Created by taqun on 2015/05/08.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

import AEXML

class FeedParserUtil: NSObject {
    
    class func getHrefLinkFromAtomData(entry: AEXMLElement) -> (String) {
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
