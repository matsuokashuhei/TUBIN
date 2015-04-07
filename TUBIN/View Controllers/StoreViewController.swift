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

    @IBOutlet weak var titleLabel: UILabel! {
        didSet { titleLabel.text = NSLocalizedString("WHAT'S INCLUDED", comment: "WHAT'S INCLUDED") }
    }
    @IBOutlet weak var text1Label: UILabel! {
        didSet { text1Label.text = NSLocalizedString("No advertisement", comment:"No advertisement")}
    }
    @IBOutlet weak var text2Label: UILabel! {
        didSet { text2Label.text = NSLocalizedString("Unlimited favorites", comment: "Unlimited favorites") }
    }
    @IBOutlet weak var text3Label: UILabel! {
        didSet { text3Label.text = NSLocalizedString("Unlimited bookmarks", comment: "Unlimited bookmarks") }
    }
    @IBOutlet weak var text4Label: UILabel! {
        didSet { text4Label.text = NSLocalizedString("One time fee for parmanent use", comment: "One time fee for parmanent use") }
    }
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var upgradeButton: UIButton! {
        didSet {
            upgradeButton.setTitle(NSLocalizedString("UPGRADE", comment: "UPGRADE"), forState: .Normal)
            if SKPaymentQueue.canMakePayments() {
                upgradeButton.addTarget(self, action: "upgradeButtonClicked:", forControlEvents: .TouchUpInside)
            }
            upgradeButton.enabled = false
        }
    }

    @IBOutlet weak var restoreButton: UIButton! {
        didSet {
            restoreButton.setTitle(NSLocalizedString("RESTORE", comment: "RESTORE"), forState: .Normal)
            if SKPaymentQueue.canMakePayments() {
                restoreButton.addTarget(self, action: "restoreButtonClicked:", forControlEvents: .TouchUpInside)
            }
            restoreButton.enabled = false
        }
    }

    convenience override init() {
        self.init(nibName: "StoreViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        navigationItem.title = NSLocalizedString("Upgrade", comment: "Upgrade")

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

}

extension StoreViewController: SKProductsRequestDelegate {

    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        if let product = response.products.first as? SKProduct {
            self.product = product
            if let price = formatPrice(product) {
                priceLabel.text = price
                upgradeButton.enabled = true
                restoreButton.enabled = true
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

    func upgradeApp() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: UpgradeAppNotification, object: self))
        if let navigationController = navigationController {
            navigationController.popViewControllerAnimated(true)
        }
    }

    func restoreApp() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: RestoreAppNotification, object: self))
        if let navigationController = navigationController {
            navigationController.popViewControllerAnimated(true)
        }
    }
}