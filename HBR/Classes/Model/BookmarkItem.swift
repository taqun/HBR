//
//  BookmarkItem.swift
//  HBR
//
//  Created by taqun on 2014/09/15.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class BookmarkItem: NSObject {
    
    var data: AnyObject
    var user: String!
    var date: NSDate!
    var dateString: String!
    var comment: String!
    
    var iconUrl: String!
    
    
    /*
     * Initialize
     */
    init(data: AnyObject){
        self.data = data
        
        super.init()
        
        self.parseData()
    }
    
    
    /*
     * Private Method
     */
    private func parseData(){
        self.user       = self.data["user"] as! String
        self.comment    = self.data["comment"] as! String
        
        //2014/10/04 16:47:18
        let dateString = self.data["timestamp"] as! String
        self.date       = DateUtil.dateFromDateString(dateString, inputFormat: "yyyy/MM/dd HH:mm:ss")
        self.dateString = DateUtil.stringFromDateString(dateString, inputFormat: "yyyy/MM/dd HH:mm:ss")
        
        let prefix = (self.user as NSString).substringToIndex(2)
        self.iconUrl = "http://cdn1.www.st-hatena.com/users/" + prefix + "/" + self.user + "/profile.gif"
    }
    
}
