//
//  StoreViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import StoreKit
import XCGLogger
import Reachability
//import ReachabilitySwift

class StoreViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    var product: SKProduct?

    @IBOutlet weak var textLabel1: UILabel! {
        didSet { textLabel1.text = NSLocalizedString("Enjoy ad-free watching on iOS.", comment: "Enjoy ad-free watching on iOS.") }
    }
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton! {
        didSet {
            purchaseButton.setTitle(NSLocalizedString("PURCHASE", comment: "PURCHASE"), forState: .Normal)
            purchaseButton.enabled = false
            if SKPaymentQueue.canMakePayments() {
                purchaseButton.addTarget(self, action: "purchaseButtonClicked:", forControlEvents: .TouchUpInside)
            }
        }
    }
    @IBOutlet weak var restoreButton: UIButton! {
        didSet {
            restoreButton.setTitle(NSLocalizedString("RESTORE", comment: "RESTORE"), forState: .Normal)
            restoreButton.enabled = false
            if SKPaymentQueue.canMakePayments() {
                restoreButton.addTarget(self, action: "restoreButtonClicked:", forControlEvents: .TouchUpInside)
            }
        }
    }
    @IBOutlet weak var textLabel2: UILabel! {
        didSet { textLabel2.text = NSLocalizedString("One time payment for parmanent use", comment: "One time payment for parmanent use") }
    }

    convenience init() {
        self.init(nibName: "StoreViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        navigationItem.title = NSLocalizedString("Ad-free on iOS", comment: "Ad-free on iOS")

        if SKPaymentQueue.canMakePayments() {
            requestProduct()
        }
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func requestProduct() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        let request = SKProductsRequest(productIdentifiers: Set(["org.matsuosh.TUBIN.AdFree"]))
        request.delegate = self
        request.start()
    }

    func purchaseButtonClicked(sender: UIButton) {
        guard let product = self.product else {
            return
        }
        do {
            if try Reachability.reachabilityForInternetConnection().isReachable() {
                let payment = SKPayment(product: product)
                SKPaymentQueue.defaultQueue().addPayment(payment)
            }
        } catch let error as NSError {
            logger.error(error.description)
            return
        }
    }

    func restoreButtonClicked(sender: UIButton) {
        do {
            if try Reachability.reachabilityForInternetConnection().isReachable() {
                Spinner.show(options: ["allowUserInteraction": false])
                SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
            }
        } catch let error as NSError {
            logger.error(error.description)
            return
        }
    }

}

extension StoreViewController: SKProductsRequestDelegate {

    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if let product = response.products.first {
            self.product = product
            if let price = formatPrice(product) {
                priceLabel.text = price
                purchaseButton.enabled = true
                restoreButton.enabled = true
            }
        }
    }

    func request(request: SKRequest, didFailWithError error: NSError) {
        logger.debug("error: \(error.localizedDescription)")
    }

    func requestDidFinish(request: SKRequest) {
        logger.debug("")
    }

    private func formatPrice(product: SKProduct) -> String? {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.locale = product.priceLocale
        let price = numberFormatter.stringFromNumber(product.price)
        if let price = price {
            return price
        }
        return nil
    }

}

extension StoreViewController: SKPaymentTransactionObserver {

    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        logger.debug("")
        for transaction in transactions {
            // トランザクションの状況
            switch transaction.transactionState {
            case .Purchasing:
                logger.debug("Purchasing")
                Spinner.show(options: ["allowUserInteraction": false])
            case .Purchased:
                logger.debug("Purchased")
                upgradeApp()
                Spinner.dismiss()
            case .Failed:
                logger.debug("Failed")
                Spinner.dismiss()
                let message: String = {
                    if let error = transaction.error {
                        return error.localizedDescription
                    } else {
                        return ""
                    }
                }()
                let alert = UIAlertController(title: NSLocalizedString("Failed", comment: "Failed"), message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismis", comment: "Dismis"), style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            case .Restored:
                logger.debug("Restored")
                restoreApp()
                Spinner.dismiss()
            case .Deferred:
                logger.debug("Defered")
                Spinner.dismiss()
            }
            // トランザクションの終了
            switch transaction.transactionState {
            case .Purchased, .Failed, .Restored:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }

    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        logger.debug("")
    }

    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        logger.debug("")
        Spinner.dismiss()
    }

    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        logger.debug("")
        Spinner.dismiss()
    }

    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        logger.debug("")
    }

    func upgradeApp() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: UpgradeAppNotification, object: self))
        let alert = UIAlertController(title: NSLocalizedString("Success", comment: "Success"), message: "", preferredStyle: .Alert)
        let action = UIAlertAction(title: NSLocalizedString("Dismis", comment: "Dismis"), style: .Default) { (action) in
            if let navigationController = self.navigationController {
                navigationController.popViewControllerAnimated(true)
            }
        }
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func restoreApp() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: RestoreAppNotification, object: self))
        let alert = UIAlertController(title: NSLocalizedString("Success", comment: "Success"), message: "", preferredStyle: .Alert)
        let action = UIAlertAction(title: NSLocalizedString("Dismis", comment: "Dismis"), style: .Default) { (action) in
            if let navigationController = self.navigationController {
                navigationController.popViewControllerAnimated(true)
            }
        }
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}