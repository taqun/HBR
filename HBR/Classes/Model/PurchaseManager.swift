//
//  PurchaseManager.swift
//  HBR
//
//  Created by taqun on 2015/04/30.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    private var product: SKProduct!
    
    private var _transactionState: SKPaymentTransactionState!
    private var _restoreState: RestoreTransactionState = RestoreTransactionState.None
    
    
    /*
     * Initialize
     */
    static var sharedInstance: PurchaseManager = PurchaseManager()
    
    override init() {
        super.init()
    }
    
    
    /*
     * Public Method
     */
    func canMakePayments() -> (Bool) {
        return SKPaymentQueue.canMakePayments()
    }
    
    func fetchProductInfo() {
        if !ModelManager.sharedInstance.adsEnabled {
            return
        }
        
        if !SKPaymentQueue.canMakePayments() {
            return
        }
        
        if self.product != nil {
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let set = NSSet(object: Setting.iapProductId())
        let request = SKProductsRequest(productIdentifiers: set as Set<NSObject>)
        request.delegate = self
        request.start()
    }
    
    func getProduct() -> (SKProduct!) {
        return self.product
    }
    
    func paymentTransaction() {
        if self.product == nil {
            return
        }
    
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        let payment = SKPayment(product: self.product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func restoreTransaction() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        self.restoreTransactionState = RestoreTransactionState.Restoreing
        
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    
    /*
     * Getter, Setter
     */
    var transactionState: SKPaymentTransactionState {
        set(newState){
            let stateChanged = (_transactionState != newState)
            _transactionState = newState
            
            if stateChanged {
                NSNotificationCenter.defaultCenter().postNotificationName("TransactionStateChangedNotification", object: nil)
            }
        }
        
        get {
            return _transactionState
        }
    }
    
    var restoreTransactionState: RestoreTransactionState {
        set(newState) {
            let stateChanged = (_restoreState != newState)
            _restoreState = newState
            
            if stateChanged {
                NSNotificationCenter.defaultCenter().postNotificationName("RestoreTransactionStateChangedNotification", object: nil)
            }
        }
        
        get {
            return _restoreState
        }
    }
    
    
    /*
     * SKProductsRequestDelegate
     */
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        if response.invalidProductIdentifiers.count > 0 {
            println(response.invalidProductIdentifiers)
            return
        }
        
        if response.products.count > 0 {
            if var products = response.products as? [SKProduct] {
                if products.count > 0 {
                    self.product = products[0]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("GetProductInfoNotification", object: nil)
               }
            }
        }
    }
    
    /*
    * SKPaymentTransactionObserver
    */
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        if let localTransactions = transactions as? [SKPaymentTransaction] {
            for transaction in localTransactions {
                switch transaction.transactionState {
                    case .Purchasing:
                        println("update transaction: purchasing")
    
                        break
    
                    case .Purchased:
                        println("update transaction: purchased")
                        ModelManager.sharedInstance.adsEnabled = false
                        queue.finishTransaction(transaction)
    
                        break
    
                    case .Failed:
                        println("update transaction: failed")
                        println(transaction.error)
    
                        break
    
                    case .Restored:
                        println("update transaction: restored")
                        queue.finishTransaction(transaction)
    
                        break
    
                    default:
                        break
                }
                
                self.transactionState = transaction.transactionState
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
        
        println("remove transactions")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
        
        ModelManager.sharedInstance.adsEnabled = false
        self.restoreTransactionState = RestoreTransactionState.Complete
        
        println("restoreCompleted")
    }
    
    func paymentQueue(queue: SKPaymentQueue!, restoreCompletedTransactionsFailedWithError error: NSError!) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
        
        self.restoreTransactionState = RestoreTransactionState.Failed
        
        println("restoreCompletedFailed")
        println(error)
    }
   
}
