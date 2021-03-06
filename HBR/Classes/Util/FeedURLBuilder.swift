//
//  FeedURLBuilder.swift
//  HBR
//
//  Created by taqun on 2015/06/23.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class FeedURLBuilder: NSObject {
    
    private static var HATENA_CATEGORY_PATH: [HatenaCategory: String] = [
        HatenaCategory.General          : "general",
        HatenaCategory.Social           : "social",
        HatenaCategory.Economics        : "economics",
        HatenaCategory.Life             : "life",
        HatenaCategory.Knowledge        : "knowledge",
        HatenaCategory.It               : "it",
        HatenaCategory.Fun              : "fun",
        HatenaCategory.Entertainment    : "entertainment",
        HatenaCategory.Anime            : "game"
    ]
    
    
    /*
     * Public Method
     */
    static func buildFeedURL(channel: Channel) -> (String) {
        switch channel.type {
            case ChannelType.Hot:
                return FeedURLBuilder.buildHotEntryFeedURL(channel.category)
            
            case ChannelType.New:
                return FeedURLBuilder.buildNewEntryFeedURL(channel.category)
            
            default:
                return FeedURLBuilder.buildKeywordFeedURL(channel.type, keyword: channel.keyword, bookmarkNum: channel.bookmarkNum)
            
            }
    }
    
    
    /*
     * Private Method
     */
    private static func buildHotEntryFeedURL(category: HatenaCategory) -> (String) {
        if category == HatenaCategory.All {
            return "http://b.hatena.ne.jp/hotentry.rss"
        } else {
            let path = HATENA_CATEGORY_PATH[category]!
            return "http://b.hatena.ne.jp/hotentry/\(path).rss"
        }
    }
    
    private static func buildNewEntryFeedURL(category: HatenaCategory) -> (String) {
        if category == HatenaCategory.All {
            return "http://b.hatena.ne.jp/entrylist?sort=hot&threshold=3&mode=rss"
        } else {
            let path = HATENA_CATEGORY_PATH[category]!
            return "http://b.hatena.ne.jp/entrylist/\(path)?sort=hot&threshold=3&mode=rss"
        }
    }
    
    private static func buildKeywordFeedURL(type: ChannelType, keyword: String, bookmarkNum: NSNumber) -> (String) {
        let escapedKeyword = keyword.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let typeString = type.rawValue
        
        return "http://b.hatena.ne.jp/search/\(typeString)?safe=on&q=\(escapedKeyword)&users=\(bookmarkNum)&mode=rss"
    }
    
}
