//
//  HBRLicensesViewController.swift
//  HBR
//
//  Created by taqun on 2015/05/15.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class LicensesViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Logger.sharedInstance.track("SettingView/LicensesView")
    }

}
