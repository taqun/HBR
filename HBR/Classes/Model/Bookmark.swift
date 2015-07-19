//
//  Bookmark.swift
//  HBR
//
//  Created by taqun on 2014/09/15.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class Bookmark: NSObject {
    
    var data: AnyObject
    
    var items: [BookmarkItem] = []
    
    
    /*
     * Initialize
     */
    init(data: AnyObject){
        self.data = data
        
        super.init()
        
        self.parseData()
    }
    
    
    /*
     * Public Method
     */
    func getCommentItem(index: Int) -> (BookmarkItem) {
        var predicate = NSPredicate(format: "comment != nil AND comment != ''")
        var filteredArray = NSArray(array: items).filteredArrayUsingPredicate(predicate) as! [BookmarkItem]
        
        return filteredArray[index]
    }
    
    
    /*
     * Private Method
     */
    private func parseData(){
        if var bookmarks: NSArray = self.data["bookmarks"] as? NSArray {
            for bookmark in bookmarks {
                let item = BookmarkItem(data: bookmark)
                self.items.append(item)
            }
            
            func bookmarkSort(b1: BookmarkItem, b2: BookmarkItem) -> (Bool) {
                return b1.date.timeIntervalSinceNow > b2.date.timeIntervalSinceNow
            }
            
            self.items = sorted(self.items, bookmarkSort)
        }
    }
    
    
    /*
     * Getter, Setter
     */
    var commentItemCount: Int {
        get {
            var predicate = NSPredicate(format: "comment != nil AND comment != ''")
            var filteredArray = NSArray(array: items).filteredArrayUsingPredicate(predicate) as! [BookmarkItem]
            
            return filteredArray.count
        }
    }
    
}
