//
//  Alert.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/13.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import TAOverlay

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
    }

    func error(error: NSError?) {
        if let error = error {
            TAOverlay.setOverlayLabelFont(UIFont(name: Appearance.Font.name, size:14)!)
            TAOverlay.showOverlayWithLabel(error.localizedDescription, options: .OverlaySizeRoundedRect | .OverlayTypeError | .OverlayTypeText | .OverlayDismissTap | .AutoHide)
        } else {
            TAOverlay.showOverlayWithLabel(nil, options: .OverlaySizeRoundedRect | .OverlayTypeError | .AllowUserInteraction | .AutoHide)
        }
    }

    func success(message: String) {
        TAOverlay.showOverlayWithLabel(nil, options: .OverlaySizeRoundedRect | .OverlayTypeSuccess | .AllowUserInteraction | .AutoHide)
    }
}
