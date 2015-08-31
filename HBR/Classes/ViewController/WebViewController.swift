//
//  WebViewController.swift
//  HBR
//
//  Created by taqun on 2014/09/13.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

import TUSafariActivity
import HatenaBookmarkSDK

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var item: Item!
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var dummyToolBar: UIToolbar!
    @IBOutlet var btnAction: UIBarButtonItem!
    
    var titleView: UILabel!
    
    var btnBack: UIBarButtonItem!
    var btnReload: UIBarButtonItem!
    var btnStop: UIBarButtonItem!
    var btnBookmark: UIBarButtonItem!
    var btnUserNum: UIBarButtonItem!
    
    var bookmarkViewController: BookmarkViewController!
    var bookmarkListIsShowed = false
    
    var htmlLinkClicked = false
    
    
    /*
     * Initialize
     */
    init(item: Item){
        self.item = item
        ModelManager.sharedInstance.currentUrl = self.item.link
        
        super.init(nibName: "WebViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        self.webView.scalesPageToFit = true
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.item.link)!))
    }
    
    
    /*
     * Private Method
     */
    @objc private func bookmarkCountUpdated() {
        let bookmarkCount = ModelManager.sharedInstance.currentBookmarkCount
        
        if bookmarkCount == 0 {
            self.btnUserNum.enabled = false
        } else {
            self.btnUserNum.enabled = true
        }
        
        self.btnUserNum.title = String(bookmarkCount) + " users"
    }
    
    @objc private func didBack(){
        self.webView.goBack()
    }
    
    @objc private func didReload(){
        if !self.webView.loading {
            self.webView.reload()
        }
    }
    
    @objc private func didStop(){
        self.webView.stopLoading()
    }
    
    @objc private func didBookmark() {
        var viewController = HTBHatenaBookmarkViewController()
        viewController.URL = self.webView.request?.URL
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    @objc private func didAction() {
        let url = NSURL(string: item.link)!
        let safariActivity = TUSafariActivity()
        
        var activityController = UIActivityViewController(activityItems: [url], applicationActivities: [safariActivity])
        self.presentViewController(activityController, animated: true, completion: {})
    }
    
    @objc private func didUserNum(){
        
        if self.bookmarkViewController == nil {
            self.bookmarkViewController = BookmarkViewController()
            self.bookmarkViewController.setSize(self.view.frame)
            
            self.addChildViewController(self.bookmarkViewController)
            self.bookmarkViewController.didMoveToParentViewController(self)
        }
        
        if self.bookmarkListIsShowed {
            self.hideBookmarkList()
        }else{
            self.showBookmarkList()
        }
    }
    
    private func showBookmarkList(){
        self.bookmarkListIsShowed = true
        
        self.bookmarkViewController.url = ModelManager.sharedInstance.currentUrl
        
        var frame = self.bookmarkViewController.view.frame
        frame.size.height = self.view.frame.height
        frame.origin.y = frame.size.height
        self.bookmarkViewController.view.frame = frame
        self.view.addSubview(self.bookmarkViewController.view)
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                var frame = self.bookmarkViewController.view.frame
                frame.origin.y = 0
                self.bookmarkViewController.view.frame = frame
            }, completion: { finished in
                
            }
        )
    }
    
    private func hideBookmarkList(){
        self.bookmarkListIsShowed = false
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                var frame = self.bookmarkViewController.view.frame
                frame.origin.y = self.view.frame.height
                self.bookmarkViewController.view.frame = frame
            }, completion: { finished in
                self.bookmarkViewController.view.removeFromSuperview()
            }
        )
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // navigationbar
        let bounds = self.navigationController?.navigationBar.bounds
        self.titleView = UILabel(frame: bounds!)
        self.titleView.font = UIFont.boldSystemFontOfSize(14)
        self.titleView.textColor = UIColor.whiteColor()
        self.titleView.textAlignment = NSTextAlignment.Center;
        self.titleView.text = self.item.title
        
        self.navigationItem.titleView = self.titleView
        
        btnAction.target = self
        btnAction.action = Selector("didAction")
        self.navigationItem.rightBarButtonItem = btnAction
        
        // toolbar
        self.navigationController?.toolbarHidden = false
        
        let toolbaItems = self.dummyToolBar.items
        self.setToolbarItems(toolbaItems, animated: false)
        
        if let tbItems = toolbarItems as? [UIBarButtonItem] {
            self.btnBack = tbItems[0]
            self.btnBack.target = self
            self.btnBack.action = Selector("didBack")
            self.btnBack.enabled = false
            
            self.btnReload = tbItems[2]
            self.btnReload.target = self
            self.btnReload.action = Selector("didReload")
            
            self.btnStop = tbItems[4]
            self.btnStop.target = self
            self.btnStop.action = Selector("didStop")
            
            self.btnBookmark = tbItems[6]
            self.btnBookmark.target = self
            self.btnBookmark.action = Selector("didBookmark")
            
            self.btnUserNum = tbItems[8]
            if self.item.userNum != nil {
                self.btnUserNum.title = self.item.userNum + " users"
            }
            self.btnUserNum.target = self
            self.btnUserNum.action = Selector("didUserNum")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("bookmarkCountUpdated"), name: Notification.BOOKMARK_COUNT_UPDATED, object: nil)
        
        if self.item.userNum == nil {
            ModelManager.sharedInstance.updateBookmarkCount(self.item.link)
        }
        
        Logger.sharedInstance.track("WebView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if webView.loading {
            webView.stopLoading()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    /*
     * UIWebView Delegate
     */
    var startLoadCount = 0
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.startLoadCount++
        
        if htmlLinkClicked == true {
            let title = webView.stringByEvaluatingJavaScriptFromString("document.title")
            if self.titleView.text != title && title != ""{
                self.titleView.text = title
            }
            ModelManager.sharedInstance.currentUrl = webView.stringByEvaluatingJavaScriptFromString("document.URL")!
        }
        
        if(self.startLoadCount == 1){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        item.read = true
        
        self.startLoadCount--
        
        if(self.startLoadCount == 0){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        if webView.canGoBack{
            self.btnBack.enabled = true
        }else{
            self.btnBack.enabled = false
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println("WebView Error", error.code)
        
        if error.code == NSURLErrorCancelled {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.startLoadCount = 0
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            htmlLinkClicked = true
        }
        
        return true
    }

}
