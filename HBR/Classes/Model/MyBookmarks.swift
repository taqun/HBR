//
//  HBRMMyBookmarks.swift
//  HBR
//
//  Created by taqun on 2015/05/07.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import CoreData


class MyBookmarks: Channel {
    
    static func findAll() -> ([MyBookmarks]) {
        let context = CoreDataManager.sharedInstance.managedObjectContext!
        
        var request = NSFetchRequest()
        request.entity = CoreDataManager.sharedInstance.getEntityByName("MyBookmarks", context: context)
        
        var error: NSError? = nil
        
        if let results = context.executeFetchRequest(request, error: &error) as? [MyBookmarks] {
            return results
        } else {
            return []
        }
    }
    
}
