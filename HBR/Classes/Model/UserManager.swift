//
//  UserManager.swift
//  HBR
//
//  Created by taqun on 2015/05/02.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

import Alamofire
import AEXML
import MagicalRecord
import HatenaBookmarkSDK

class UserManager: NSObject {
    
    var oauthRequest: NSURLRequest!
    
    /*
     * Initialize
     */
    static var sharedInstance: UserManager = UserManager()
    
    override init() {
        super.init()
    }
    
    
    /*
     * Public Method
     */
    func login() {
        Logger.log("HTB: authorize")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showOAuthLoginView:"), name: kHTBLoginStartNotification, object: nil)
        
        HTBHatenaBookmarkManager.sharedManager().authorizeWithSuccess({ () -> Void in
                self.loginComplete()
            }, failure: { (error: NSError!) -> Void in
                self.loginComplete()
            }
        )
    }
    
    private func loginComplete() {
        NSNotificationCenter.defaultCenter().postNotificationName("OAuthCompleteNotification", object: nil)
    }
    
    func logout() {
        HTBHatenaBookmarkManager.sharedManager().logout()
    }
    
    func loadMyBookmarks() {
        let url = NSURL(string: "http://b.hatena.ne.jp")
        let client = HTBAFOAuth1Client(baseURL: url, key: Setting.HB_CONSUMER_KEY, secret: Setting.HB_CONSUMER_SECRET)
        client.accessToken = HTBHatenaBookmarkManager.sharedManager().apiClient.accessToken
        
        let request = client.requestWithMethod("GET", path: "/atom/feed", parameters: nil)
        
        Alamofire.request(request)
            .validate()
            .response { (request, response, data, error) in
                if error != nil {
                    
                    println(response)
                    println(error?.localizedDescription)
                    
                    self.loadMyBookmarksFailed()
                    
                } else {
                    
                    var newItems = [Item]()
                    var error: NSError?
                    
                    if let data = data as? NSData {
                        if let xml = AEXMLDocument(xmlData: data, error: &error) {
                            if let entries = xml.root["entry"].all {
                                let myBookmarks = ModelManager.sharedInstance.myBookmarksChannel
                                let context = myBookmarks.managedObjectContext
                                
                                for entry in entries {
                                    let link = FeedParserUtil.getHrefLinkFromAtomData(entry)
                                    
                                    var predicate = NSPredicate(format: "ANY channels = %@ AND link == %@", myBookmarks, link)
                                    var items = Item.MR_findAllWithPredicate(predicate, inContext: myBookmarks.managedObjectContext) as! [Item]
                                    
                                    if items.count == 0 {
                                        var item = Item.MR_createInContext(context) as! Item
                                        item.parseXMLData(entry)
                                        newItems.append(item)
                                    }
                                }
                            }
                        }
                    }
                    
                    self.loadMyBookmarksComplete(newItems)
                }
            }
    }
    
    private func loadMyBookmarksComplete(newItems: [Item]) {
        let myBookmarks = ModelManager.sharedInstance.myBookmarksChannel
        
        MagicalRecord.saveUsingCurrentThreadContextWithBlock({ (localContext) -> Void in
            var localChannel = myBookmarks.MR_inContext(localContext) as! Channel
            localChannel.addItems(newItems)
        }, completion: { (success, error) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MyBookmarksLoadedNotification", object: nil)
        })
    }
    
    private func loadMyBookmarksFailed() {
        NSNotificationCenter.defaultCenter().postNotificationName("MyBookmarksLoadedNotification", object: nil)
    }
    
    
    /*
     * Private Method
     */
    @objc func showOAuthLoginView(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kHTBLoginStartNotification, object: nil)
        
        if let request = notification.object as? NSURLRequest {
            self.oauthRequest = request
            
            NSNotificationCenter.defaultCenter().postNotificationName("readyOAuthNotification", object: nil)
        }
    }
    
    
    /*
     * Getter, Setter
     */
    var isLoggedIn: Bool {
        get {
            return HTBHatenaBookmarkManager.sharedManager().authorized
        }
    }
    
    var username: String! {
        get {
            return HTBHatenaBookmarkManager.sharedManager().username
        }
    }
   
}
