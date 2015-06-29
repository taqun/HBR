//
//  DateUtil.swift
//  HBR
//
//  Created by taqun on 2014/10/04.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class DateUtil: NSObject {
    
    class func dateFromDateString(dateString: String, inputFormat: String) -> (NSDate!){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = inputFormat
        
        return dateFormatter.dateFromString(dateString)
    }
   
    class func stringFromDateString(dateString: String, inputFormat: String) -> (String){
        let dateFormatter1 = NSDateFormatter()
        dateFormatter1.dateFormat = inputFormat
        
        let date = dateFormatter1.dateFromString(dateString)
        
        let dateFormatter2 = NSDateFormatter()
        dateFormatter2.dateFormat = "yyyy/MM/dd HH:mm"
        
        return dateFormatter2.stringFromDate(date!)
    }
    
    class func getExpireDateValue(expireInterval: EntryExpireInterval) -> (Int) {
        switch expireInterval {
            case EntryExpireInterval.ThreeDays:
                return 3
            case EntryExpireInterval.OneWeek:
                return 7
            case EntryExpireInterval.OneMonth:
                return 30
            case EntryExpireInterval.None:
                return 0
            default:
                return 0
        }
    }
    
}
