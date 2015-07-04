//
//  AppDelegate.swift
//  HBR
//
//  Created by taqun on 2015/06/27.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

import GoogleAnalytics_iOS_SDK
import HatenaBookmarkSDK
import MagicalRecord
import iConsole
//import Fabric
//import Crashlytics

@UIApplicationMain
class HBRAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    /*
    * Initialize
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        #if DEBUG
        self.window = iConsoleWindow(frame: UIScreen.mainScreen().bounds)
        #else
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        #endif
        
        let storyBoard = UIStoryboard(name: "IndexViewController", bundle: nil)
        let controller = storyBoard.instantiateInitialViewController() as! IndexViewController
        let navigationController = NavigationControllerUtil.getNavigationController(controller)
        
        self.window?.rootViewController = navigationController
        
        AppAppearance.setup()
        
        self.configureLibraries()
        self.configureBackgroundFetch()
        self.configureNotifications()
        self.configureDebugTools()
        
        window?.makeKeyAndVisible()
        
        PurchaseManager.sharedInstance.fetchProductInfo()
        
        Logger.log("[AppDelegate] didFinishLaunching")
        
        return true
    }
    
    func configureLibraries() {
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed("HBR.sqlite")

        HTBHatenaBookmarkManager.sharedManager().setConsumerKey(Setting.hbConsumerKey(), consumerSecret: Setting.hbConsumerSecret())
        
        //Fabric.with([Crashlytics()])
    }
    
    func configureBackgroundFetch() {
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    }
    
    func configureNotifications() {
        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func configureDebugTools() {
        iConsole.sharedConsole().deviceTouchesToShow = 2
    }
    
    
    /*
    * UIApplicationDelegate
    */
    func applicationWillResignActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Logger.log("[AppDelegate] didEnterBackground")
        
        ModelManager.sharedInstance.save()
        
        if (application.currentUserNotificationSettings().types & UIUserNotificationType.Badge) != nil {
            UIApplication.sharedApplication().applicationIconBadgeNumber = ModelManager.sharedInstance.getAllUnreadItemCount()
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Logger.log("[AppDelegate] willEnterForeground")
        
        PurchaseManager.sharedInstance.fetchProductInfo()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        MagicalRecord.cleanUp()
    }
    
    
    /*
    * Background Fetch
    */
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Logger.log("")
        Logger.log("=================================")
        Logger.log("performFetchWithCompletionHandler")
        
        FeedController.sharedInstance.performFetchWithCompletionHandler(completionHandler)
    }
    
}