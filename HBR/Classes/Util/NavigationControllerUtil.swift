//
//  HBRNavigationControllerUtil.swift
//  HBR
//
//  Created by taqun on 2014/10/27.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class NavigationControllerUtil: NSObject {
    
    class func getNavigationController(rootViewController: UIViewController) -> (UINavigationController) {
        var navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.translucent = false
        navigationController.toolbar.translucent = false
        
        return navigationController
    }
    
}
