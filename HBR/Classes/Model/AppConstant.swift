//
//  AppConstant.swift
//  HBR
//
//  Created by taqun on 2014/11/21.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class AppConstant: NSObject {
   
}

enum EntryExpireInterval: String {
    case ThreeDays  = "3日"
    case OneWeek    = "1週間"
    case OneMonth   = "1ヶ月"
    case None       = "すべて"
}

enum RestoreTransactionState: String {
    case Restoreing = "restoreingTransaction"
    case Complete   = "completeRestoreTransaction"
    case Failed     = "failedRestoreTransaction"
    case None       = "notRestoreTransaction"
}
