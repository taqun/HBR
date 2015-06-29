//
//  SettingViewController.swift
//  HBR
//
//  Created by taqun on 2014/10/27.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit
import StoreKit

import HatenaBookmarkSDK
import MBProgressHUD

class SettingViewController: UITableViewController {
    
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var loginLabel: UILabel!
    
    @IBOutlet var expireLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    
    @IBOutlet var productCell: UITableViewCell!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!
    @IBOutlet var restoreCell: UITableViewCell!
    @IBOutlet var restoreLabel: UILabel!
    
    var onComplete: (() -> (Void))!
    
    private var progressIndicatorIsShowing:Bool = false
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /*
     * Private Method
     */
    func didClose() {
        self.onComplete()
    }
    
    private func updateAccountLabels() {
        if let username = UserManager.sharedInstance.username {
            accountLabel.text = username
        } else {
            accountLabel.text = "未ログイン"
        }
        
        if UserManager.sharedInstance.isLoggedIn {
            loginLabel.text = "ログアウト"
        } else {
            loginLabel.text = "ログイン"
        }
    }
    
    @objc private func showOAuthView() {
        let request = UserManager.sharedInstance.oauthRequest
        
        let navigationController = UINavigationController(navigationBarClass: HTBNavigationBar.self, toolbarClass: nil)
        let viewController = HTBLoginWebViewController(authorizationRequest: request)
        navigationController.viewControllers = [viewController]
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @objc private func oauthComplete() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func updateProductLabels() {
        if !ModelManager.sharedInstance.adsEnabled {
            self.productNameLabel.textColor     = UIColor.lightGrayColor()
            self.productPriceLabel.textColor    = UIColor.lightGrayColor()
            self.productPriceLabel.text         = "購入済み"
            self.productCell.selectionStyle     = UITableViewCellSelectionStyle.None
            
            self.restoreLabel.textColor         = UIColor.lightGrayColor()
            self.restoreCell.selectionStyle     = UITableViewCellSelectionStyle.None
            
            
            return
        }
        
        if PurchaseManager.sharedInstance.canMakePayments() {
            if let product = PurchaseManager.sharedInstance.getProduct() {
                self.productNameLabel.text      = product.localizedTitle
                self.productPriceLabel.text     = "¥ " + product.price.stringValue
            }
        } else {
            self.productNameLabel.textColor     = UIColor.lightGrayColor()
            self.productPriceLabel.textColor    = UIColor.lightGrayColor()
            self.productPriceLabel.text         = "利用できません"
        }
    }
    
    @objc private func paymentStateChanged() {
        let transactionState = PurchaseManager.sharedInstance.transactionState
        
        switch transactionState {
            case .Purchasing:
                self.showProgressIndicator()
                break
            
            case .Purchased:
                self.hideProgressIndicator()
                self.updateProductLabels()
                break
            
            case .Failed:
                self.hideProgressIndicator()
                break
            
            case .Restored:
                self.hideProgressIndicator()
                break
            
            case .Deferred:
                break
            
            default:
                break
        }
    }
    
    private func showProgressIndicator() {
        if self.progressIndicatorIsShowing == true {
            return
        }
    
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.progressIndicatorIsShowing = true
    }
    
    private func hideProgressIndicator() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        self.progressIndicatorIsShowing = false
    }
    
    @objc private func restoreStateChanged() {
        let restoreState = PurchaseManager.sharedInstance.restoreTransactionState
        
        switch restoreState {
            case .Restoreing:
                self.showProgressIndicator()
                break
            
            case .Complete:
                self.hideProgressIndicator()
                self.updateProductLabels()
                
                let alert = UIAlertView(title: "ありがとうございます", message: "復元が完了しました。", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                
                break
            
            case .Failed:
                self.hideProgressIndicator()
                let alert = UIAlertView(title: "エラー", message: "復元に失敗しました。", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                break
            
            default:
                break
        }
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // navigation bar
        self.title = "設定"
        
        var closeBtn = UIBarButtonItem(title: "閉じる", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("didClose"))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        // tableView
        expireLabel.text = ModelManager.sharedInstance.entryExpireInterval.rawValue
        versionLabel.text = ModelManager.sharedInstance.appVersion()
        
        self.updateAccountLabels()
        
        // in-app purchase
        self.updateProductLabels()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showOAuthView"), name: "readyOAuthNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateProductLabels"), name: "GetProductInfoNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("paymentStateChanged"), name: "TransactionStateChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("restoreStateChanged"), name: "RestoreTransactionStateChangedNotification", object: nil)
        
        Logger.sharedInstance.track("SettingView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("oauthComplete"), name: "OAuthCompleteNotification", object: nil)
    }
    
    
    /*
     * UITableView Delegate
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let section = indexPath.indexAtPosition(0)
        let index = indexPath.indexAtPosition(1)
        
        switch section {
            case 0:
                // account
                switch index {
                    case 0:
                        break
                    case 1:
                        if UserManager.sharedInstance.isLoggedIn {
                            UserManager.sharedInstance.logout()
                            
                            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                            
                            let delay = 0.5 * Double(NSEC_PER_SEC)
                            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                self.updateAccountLabels()
                                return
                            })
                            
                        } else {
                            UserManager.sharedInstance.login()
                        }
                        
                        break
                    default:
                        break
                }
            
            case 1:
                // setting
                switch index {
                    case 0:
                        let storyBoard = UIStoryboard(name: "ExpireSettingViewController", bundle: nil)
                        let expireSettingViewController = storyBoard.instantiateInitialViewController() as! ExpireSettingViewController
                        
                        self.navigationController?.pushViewController(expireSettingViewController, animated: true)
                        
                        break
                    default:
                        break
                }
                break
            
            case 2:
                // in-app purchase
                if !ModelManager.sharedInstance.adsEnabled {
                    return
                }
                
                if !PurchaseManager.sharedInstance.canMakePayments() {
                    let alert = UIAlertView(title: "エラー", message: "App内課金が制限されています。", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    return
                }
                
                if PurchaseManager.sharedInstance.getProduct() == nil {
                    return
                }
                
                switch index {
                    case 0:
                        // new
                        PurchaseManager.sharedInstance.paymentTransaction()
                        break
                    
                    case 1:
                        // restore
                        PurchaseManager.sharedInstance.restoreTransaction()
                        break
                    
                    default:
                        break
                }
                
                break
            
            case 3:
                // cache
                switch index {
                    case 0:
                        ModelManager.sharedInstance.clearCache()
                        break
                    default:
                        break
                }
                break
            case 4:
                // about
                switch index {
                    case 0:
                        // version
                        break
                    
                    case 1:
                        // terms
                        let storyBoard = UIStoryboard(name: "TermsViewController", bundle: nil)
                        let termsViewController = storyBoard.instantiateInitialViewController() as! UIViewController
                    
                        self.navigationController?.pushViewController(termsViewController, animated: true)

                    case 2:
                        // license
                        let storyBoard = UIStoryboard(name: "LicensesViewController", bundle: nil)
                        let licenseViewController = storyBoard.instantiateInitialViewController() as! UIViewController
                        
                        self.navigationController?.pushViewController(licenseViewController, animated: true)
                    
                    default:
                        break
                    
                }
                break
            
            default:
                break
        
        }
    }
}
