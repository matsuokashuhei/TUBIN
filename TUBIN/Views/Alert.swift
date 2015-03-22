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

    let logger = XCGLogger.defaultInstance()

    class var sharedInstance: Alert {
        struct Singleton {
            static let instance = Alert()
        }
        return Singleton.instance
    }

    func configure() {
        HUDController.sharedController.dimsBackground = true
        HUDController.sharedController.userInteractionOnUnderlyingViewsEnabled = true
    }

    func error(error: NSError?) {
        configure()
        let image = UIImage(named: "ic_warning_48px")
        if let error = error {
            logger.error(error.localizedDescription)
            //HUDController.sharedController.contentView = HUDContentView.StatusView(title: "ERROR", subtitle: error.localizedDescription, image: HUDAssets.crossImage)
            HUDController.sharedController.contentView = HUDContentView.StatusView(title: "ERROR", subtitle: error.localizedDescription, image: image)
        } else {
            //HUDController.sharedController.contentView = HUDContentView.SubtitleView(subtitle: "ERROR", image: HUDAssets.crossImage)
            HUDController.sharedController.contentView = HUDContentView.SubtitleView(subtitle: "ERROR", image: image)
        }
        HUDController.sharedController.show()
        HUDController.sharedController.hide(afterDelay: 1.0)
    }
}
