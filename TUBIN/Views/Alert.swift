//
//  Alert.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/13.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import PKHUD

class Alert {

    class func error(error: NSError?) {
        sharedInstance.error(error)
    }

    class func success(message: String) {
        sharedInstance.success(message)
    }

    let logger = XCGLogger.defaultInstance()

    class var sharedInstance: Alert {
        struct Singleton {
            static let instance = Alert()
        }
        return Singleton.instance
    }

    func configure() {
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
        //HUDController.sharedController.dimsBackground = true
        //HUDController.sharedController.userInteractionOnUnderlyingViewsEnabled = true
    }

    func error(error: NSError?) {
        configure()
        let title = NSLocalizedString("Error", comment: "エラーのアラートのタイトル")
        let image = UIImage(named: "ic_warning_48px")
        let message: String = {
            if let error = error {
                return error.localizedDescription
            } else {
                return ""
            }
        }()
        PKHUD.sharedHUD.contentView = PKHUDStatusView(title: title, subtitle: message, image: image)
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 3.0)
        /*
        if let error = error {
            logger.error(error.localizedDescription)
            //HUDController.sharedController.contentView = HUDContentView.StatusView(title: "ERROR", subtitle: error.localizedDescription, image: HUDAssets.crossImage)
            HUDController.sharedController.contentView = HUDContentView.StatusView(title: title, subtitle: error.localizedDescription, image: image)
        } else {
            //HUDController.sharedController.contentView = HUDContentView.SubtitleView(subtitle: "ERROR", image: HUDAssets.crossImage)
            HUDController.sharedController.contentView = HUDContentView.SubtitleView(subtitle: title, image: image)
        }
        HUDController.sharedController.show()
        HUDController.sharedController.hide(afterDelay: 1.0)
        */
    }

    func success(message: String) {
        configure()
        let title = NSLocalizedString("Success", comment: "サクセスのアラートのタイトル")
        let image = UIImage(named: "ic_check_48px")
        /*
        HUDController.sharedController.contentView = HUDContentView.StatusView(title: title, subtitle: message, image: image)
        HUDController.sharedController.show()
        HUDController.sharedController.hide(afterDelay: 1.0)
        */
        PKHUD.sharedHUD.contentView = PKHUDStatusView(title: title, subtitle: message, image: image)
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 3.0)
    }
}
