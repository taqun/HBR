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
        let client = HTBAFOAuth1Client(baseURL: url, key: Setting.hbConsumerKey(), secret: Setting.hbConsumerSecret())
        client.accessToken = HTBHatenaBookmarkManager.sharedManager().apiClient.accessToken
        
        let request = client.requestWithMethod("GET", path: "/atom/feed", parameters: nil)
        
        Alamofire.request(request)
            .validate()
            .response { (request, response, data, error) in
                if error != nil {
                    
                    println(response)
                    println(error?.localizedDescription)
                    
                    self.loadMyBookmarksComplete()
                    
                } else {
                    
                    let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    dispatch_async(globalQueue) {
                        let parser = AtomFeedParser()
                        let atomData = data as! NSData
                        
                        parser.parse(atomData, onComplete: self.parseComplete)
                    }
                }
            }
    }
    
    private func parseComplete(parser: AtomFeedParser) {
        let itemDatas = parser.itemDatas
        let myBookmarks = ModelManager.sharedInstance.myBookmarksChannel
        var newItems = [Item]()
        
        for data in itemDatas {
            let link = data["link"]!
            
            var predicate = NSPredicate(format: "ANY channels = %@ AND link == %@", myBookmarks, link)
            var items = Item.findAllWithPredicate(predicate, context: myBookmarks.managedObjectContext!)
            
            if items.count == 0 {
                var item = CoreDataManager.sharedInstance.createItemInContext(myBookmarks.managedObjectContext!)
                item.parseAtomData(data)
                println(item)
                newItems.append(item)
            }
        }
        
        self.parseMyBookmarksComplete(newItems)
    }
    
    private func parseMyBookmarksComplete(newItems: [Item]) {
        let myBookmarks = ModelManager.sharedInstance.myBookmarksChannel
        
        CoreDataManager.sharedInstance.saveContext()
        /*
        MagicalRecord.saveUsingCurrentThreadContextWithBlock({ (localContext) -> Void in
            var localChannel = myBookmarks.MR_inContext(localContext) as! Channel
            localChannel.addItems(newItems)
        }, completion: { (success, error) -> Void in
            self.loadMyBookmarksComplete()
        })
        */
    }
    
    private func loadMyBookmarksComplete() {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName("MyBookmarksLoadedNotification", object: nil)
        }
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
