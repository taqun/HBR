//
//  Appearance.swift
//  HBR
//
//  Created by taqun on 2014/09/19.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class AppAppearance: NSObject {
    
    class func setup(){
        UINavigationBar.appearance().barTintColor = UIColor(hex: 0x2b88d9, alpha: 0.5)
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
}
