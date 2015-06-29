//
//  ReportSpamActivity.swift
//  HBR
//
//  Created by taqun on 2015/05/24.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import MessageUI

class ReportSpamActivity: UIActivity, MFMailComposeViewControllerDelegate {

    var urlItem: NSURL!
    var viewController: UIViewController!
    
    
    /*
     * MFMailComposeViewControllerDelegate
     */
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.activityDidFinish(true)
    }
    
    
    /*
     * UIActivity Method
     */
    override func activityType() -> String? {
        return "net.envoix.app.HBR"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "reportActivity")
    }
    
    override func activityTitle() -> String? {
        return "通報"
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for item in activityItems {
            if item is NSURL {
                return true
            }
        }
        
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for item in activityItems {
            if let urlItem = item as? NSURL {
                self.urlItem = urlItem
            }
        }
    }
    
    override func activityViewController() -> UIViewController? {
        if MFMailComposeViewController.canSendMail() {
        
            var mailerViewController = MFMailComposeViewController()
            mailerViewController.setToRecipients(["envoixapp+hbr.report@gmail.com"])
            mailerViewController.setSubject("[HBR] 不適切なコンテンツの通報")
            mailerViewController.mailComposeDelegate = self
        
            if self.urlItem != nil {
                mailerViewController.setMessageBody("\(self.urlItem)", isHTML: false)
            }
        
            return mailerViewController
        } else {
            return nil
        }
    }
   
}
