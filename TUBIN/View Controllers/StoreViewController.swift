//
//  StoreViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import StoreKit

class StoreViewController: UIViewController {

    convenience override init() {
        self.init(nibName: "StoreViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None
        navigationItem.title = "Store"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func upgrade() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }

}

extension StoreViewController: SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        // TODO:
    }
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        // TODO:
    }
    func requestDidFinish(request: SKRequest!) {
        // TODO:
    }
    override func requestInterstitialAdPresentation() -> Bool {
        // TODO:
        return true
    }
    
}

extension StoreViewController: SKPaymentTransactionObserver {
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        // TODO:
    }
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        // TODO:
    }
    func paymentQueue(queue: SKPaymentQueue!, restoreCompletedTransactionsFailedWithError error: NSError!) {
        // TODO:
    }
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        // TODO:
    }
    func paymentQueue(queue: SKPaymentQueue!, updatedDownloads downloads: [AnyObject]!) {
        // TODO:
    }
}