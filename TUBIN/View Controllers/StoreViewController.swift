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

    let logger = XCGLogger.defaultInstance()

    var product: SKProduct?

    @IBOutlet weak var upgradeButton: UIButton! {
        didSet {
            if SKPaymentQueue.canMakePayments() {
                upgradeButton.addTarget(self, action: "upgradeButtonClicked:", forControlEvents: .TouchUpInside)
            } else {
                upgradeButton.enabled = false
            }
        }
    }

    @IBOutlet weak var restoreButton: UIButton! {
        didSet {
            if SKPaymentQueue.canMakePayments() {
                restoreButton.addTarget(self, action: "restoreButtonClicked:", forControlEvents: .TouchUpInside)
            } else {
                restoreButton.enabled = false
            }
        }
    }

    convenience override init() {
        self.init(nibName: "StoreViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        navigationItem.title = "Store"

        requestProduct()
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
        let request = SKProductsRequest(productIdentifiers: NSSet(object: "org.matsuosh.TUBIN.product1"))
        request.delegate = self
        request.start()
    }

    func upgradeButtonClicked(sender: UIButton) {
        if let product = product {
            let payment = SKPayment(product: product)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }
    }

    func restoreButtonClicked(sender: UIButton) {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }

    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }

}

extension StoreViewController: SKProductsRequestDelegate {

    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        if let product = response.products.first as? SKProduct {
            self.product = product

            if let price = formatPrice(product) {
                upgradeButton.setTitle("UPGRADE \(price)", forState: .Normal)
            }
        }
    }

    func request(request: SKRequest!, didFailWithError error: NSError!) {
        logger.debug("error: \(error.localizedDescription)")
        // TODO:
    }

    func requestDidFinish(request: SKRequest!) {
        logger.debug("")
        // TODO:
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

    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        logger.debug("")
        // TODO:
        for transaction in transactions {
            if let transaction = transaction as? SKPaymentTransaction {
                // トランザクションの状況
                switch transaction.transactionState {
                case .Purchasing:
                    logger.debug("Purchasing")
                    Spinner.show()
                case .Purchased:
                    logger.debug("Purchased")
                    Spinner.dismiss()
                case .Failed:
                    logger.debug("Failed")
                    Spinner.dismiss()
                    if let error = transaction.error {
                        let alert = UIAlertController(title: "Failed", message: error.localizedDescription, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Dismis", style: .Default, handler: nil))
                        presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Failed", message: "", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Dismis", style: .Default, handler: nil))
                        presentViewController(alert, animated: true, completion: nil)
                    }
                case .Restored:
                    logger.debug("Restored")
                    Spinner.dismiss()
                case .Deferred:
                    logger.debug("Defered")
                    Spinner.dismiss()
                }
                // トランザクションの終了
                switch transaction.transactionState {
                case .Deferred:
                    break
                default:
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                }
            }
        }
    }

    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        logger.debug("")
        // TODO:
    }

    func paymentQueue(queue: SKPaymentQueue!, restoreCompletedTransactionsFailedWithError error: NSError!) {
        logger.debug("")
        // TODO:
    }

    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        logger.debug("")
        // TODO:
    }

    func paymentQueue(queue: SKPaymentQueue!, updatedDownloads downloads: [AnyObject]!) {
        logger.debug("")
        // TODO:
    }
}