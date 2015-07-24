//
//  FeedController.swift
//  HBR
//
//  Created by taqun on 2014/09/13.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

import Alamofire

class FeedController: NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    private var channelCounter: Int = 0
    private var channelNum: Int     = 0
    
    private var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)!
    private var backgroundSession: NSURLSession!
    
    
    /*
     * Initialize
     */
    static var sharedInstance: FeedController = FeedController()
    
    override init() {
        super.init()
    }
    
    
    /*
     * Load feeds
     */
    func loadFeeds(){
        channelCounter  = 0
        channelNum      = ModelManager.sharedInstance.channelCount
        
        if channelNum == 0 {
            NSNotificationCenter.defaultCenter().postNotificationName("FeedLoadedNotification", object: nil)
        } else {
            self.loadRSS()
        }
    }
    
    func loadFeed(channelID: NSManagedObjectID){
        channelCounter  = 0
        channelNum      = 1
        
        self.loadRSS(channelID: channelID)
    }
    
    private func loadRSS(channelID: NSManagedObjectID! = nil){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let currentChannel = (channelID != nil) ? ModelManager.sharedInstance.getchannelById(channelID) : ModelManager.sharedInstance.getChannel(self.channelCounter)
        let url = currentChannel.feedURL
        
        Alamofire.request(.GET, url)
            .validate(statusCode: 200..<400)
            .validate(contentType: ["application/xml", "application/rss+xml"])
            .response { (request, response, data, error) in
                
                if error != nil {
                    
                    println(request)
                    println(error?.localizedDescription)
                    
                    self.parseComplete(nil)
                    
                } else {
                    
                    let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    dispatch_async(globalQueue) {
                        let currentChannelID = currentChannel.objectID
                        let parser = FeedParser(channelID: currentChannelID)
                        let xmlParser = NSXMLParser(data: data as! NSData)
                    
                        parser.parse(xmlParser, onComplete: self.parseComplete)
                    }
                }
        }
    }
    
    private func parseComplete(parser: FeedParser!) {
        channelCounter = channelCounter + 1
        
        if channelNum == channelCounter {
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                NSNotificationCenter.defaultCenter().postNotificationName("FeedLoadedNotification", object: nil)
            }
            
            channelCounter = 0
            
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.loadRSS()
            }
        }
    }
    
    
    /*
     * Load Bookmarks
     */
    func loadBookmarks(url: String){
        if ModelManager.sharedInstance.getBookmark(url) != nil {
            NSNotificationCenter.defaultCenter().postNotificationName("BookmarkLoadedNotification", object: nil)
            
            return
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("BookmarkLoadStartNotification", object: nil)
        
        let url = "http://b.hatena.ne.jp/entry/jsonlite/" + url
        
        Alamofire.request(.GET, url)
            .validate()
            .responseJSON { (request, response, json, error) in
                
                if error != nil {
                    println("HBRFeedController : error \(error?.localizedDescription)")
                    
                    self.loadBookmarksError()
                } else {
                    
                    let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    dispatch_async(globalQueue) {
                        self.parseBookmarks(json)
                    }
                }
        }
    }
    
    private func parseBookmarks(responseObject: AnyObject!){
        let response = responseObject as! [String: AnyObject]
        let url = response["url"]! as! String
        let bookmark = Bookmark(data: response)

        ModelManager.sharedInstance.addBookmark(url, bookmark: bookmark)
        
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName("BookmarkLoadedNotification", object: nil)
        }
    }
    
    private func loadBookmarksError() {
        NSNotificationCenter.defaultCenter().postNotificationName("BookmarkLoadedNotification", object: nil)
    }
    
    
    /*
     * Background Fetch
     */
    func performFetchWithCompletionHandler(completionHandler: (UIBackgroundFetchResult) -> Void) {
        ModelManager.sharedInstance.truncateExpiredEntries()
        
        Logger.log("fetch start")
        Logger.log("---------------------------------")
        
        self.fetchCompletionHandler = completionHandler
        
        if backgroundSession == nil {
            var sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("net.envoix.app.HBR")
            sessionConfig.timeoutIntervalForRequest     = 15.0
            sessionConfig.timeoutIntervalForResource    = 20.0
            
            backgroundSession = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        }
        
        self.backgroundLoadRSS()
    }
    
    func backgroundLoadRSS() {
        var channel = ModelManager.sharedInstance.getOldestChannel()
        
        if channel == nil {
            Logger.log("channel is nil on backgroundLoadRSS")
            self.backgroundParseComplete(nil)
            
            return
        }
        
        Logger.log("[load rss] \(channel.title)")
        
        var url = NSURL(string: channel.feedURL)
        var request = NSMutableURLRequest(URL: url!)
        NSURLProtocol.setProperty(channel.objectID, forKey: "objectID", inRequest: request)
        
        var downloadTask = backgroundSession.downloadTaskWithRequest(request)
        downloadTask.taskDescription = channel.title
        downloadTask.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        Logger.log(" finishDownload : \(downloadTask.taskDescription)")

        if let response = downloadTask.response as? NSHTTPURLResponse {
            let status      = response.statusCode
            let mimeType    = response.MIMEType
            
            if status == 200 && contains(["application/xml", "application/rss+xml"], mimeType!) {
                Logger.log(" load success:  \(status), \(mimeType)")
                
                if var objectID = NSURLProtocol.propertyForKey("objectID", inRequest: downloadTask.originalRequest) as! NSManagedObjectID! {
                    NSURLProtocol.removePropertyForKey("objectID", inRequest: downloadTask.originalRequest as! NSMutableURLRequest)
                    
                    let parser = FeedParser(channelID: objectID)
                    parser.parse(NSXMLParser(contentsOfURL: location)!, onComplete: self.backgroundParseComplete)
                    
                } else {
                    self.backgroundFetchFailed("objectID is nil")
                }
            } else {
                self.backgroundFetchFailed("load failed: status = \(status), mimeType = \(mimeType)")
            }
        } else {
            self.backgroundFetchFailed("response is nil")
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            task.cancel()
            
            if let description = error?.localizedDescription {
                self.backgroundFetchFailed("load failed: \(description)")
            } else {
                self.backgroundFetchFailed("load failed: unknown error")
            }
        }
    }
    
    func backgroundParseComplete(parser: FeedParser!) {
        var addedItemNum: Int = 0
        
        if parser != nil {
            addedItemNum = parser.itemNum
            
            if parser.itemNum == 0 {
                Logger.log("  => no update")
            } else {
                Logger.log("  => add +" + String(parser.itemNum))
            }
        }
        
        var remaining = round(UIApplication.sharedApplication().backgroundTimeRemaining)
        Logger.log("  remaining = \(remaining)s")
        
        self.backgroundFetchComplete(addedItemNum: addedItemNum)
    }
    
    func backgroundFetchComplete(addedItemNum:Int = 0) {
        dispatch_async(dispatch_get_main_queue()) {
            Logger.log("---------------------------------")
            Logger.log("fetch success")
            
            UIApplication.sharedApplication().applicationIconBadgeNumber = ModelManager.sharedInstance.allUnreadItemCount
            
            ModelManager.sharedInstance.save()
            
            if(addedItemNum == 0){
                Logger.log("fetch complete : no data")
                self.fetchCompletionHandler(UIBackgroundFetchResult.NoData)
            } else {
                Logger.log("fetch complete : new data + \(addedItemNum)")
                self.fetchCompletionHandler(UIBackgroundFetchResult.NewData)
            }
            
            Logger.log("=================================")
            Logger.log("")
        }
    }
    
    func backgroundFetchFailed(reason: String!) {
        dispatch_async(dispatch_get_main_queue()) {
            Logger.log("---------------------------------")
            Logger.log("background fetch failed")
            Logger.log(" \(reason)")
            Logger.log("=================================")
            Logger.log("")
            
            self.fetchCompletionHandler(UIBackgroundFetchResult.Failed)
        }
    }
    
}
