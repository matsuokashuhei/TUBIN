//
//  Alert.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/13.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import SVProgressHUD

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
        // SVProgressHUD
        SVProgressHUD.setBackgroundColor(UIColor.whiteColor())
        SVProgressHUD.setForegroundColor(UIColor.redColor())
        SVProgressHUD.setErrorImage(UIImage(named: "ic_warning_48px"))
        SVProgressHUD.setRingThickness(4)
        SVProgressHUD.setFont(UIFont(name: "AvenirNext-Regular", size: 15.0)!)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Clear)
    }

    func error(error: NSError?) {
        configure()
        if let error = error {
            logger.error(error.localizedDescription)
        }
        SVProgressHUD.showErrorWithStatus("")
    }
}
