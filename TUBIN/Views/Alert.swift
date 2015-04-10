//
//  Alert.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/13.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import TAOverlay

class Alert {

    class func info(message: String, autoHide: Bool = true) {
        sharedInstance.info(message, autoHide: autoHide)
    }

    class func error(error: NSError?, autoHide: Bool = true) {
        sharedInstance.error(error, autoHide: autoHide)
    }

    class func success(message: String) {
        sharedInstance.success(message)
    }

    let logger = XCGLogger.defaultInstance()

    static var sharedInstance = Alert()

    func configure() {
    }

    func info(message: String, autoHide: Bool = true) {
        TAOverlay.setOverlayLabelFont(UIFont(name: Appearance.Font.name, size:14)!)
        if autoHide {
            TAOverlay.showOverlayWithLabel(message, options: .OverlaySizeRoundedRect | .OverlayTypeInfo | .OverlayTypeText | .OverlayDismissTap | .AutoHide)
        } else {
            TAOverlay.showOverlayWithLabel(message, options: .OverlaySizeRoundedRect | .OverlayTypeInfo | .OverlayTypeText | .OverlayDismissTap)
        }
    }

    func error(error: NSError?, autoHide: Bool = true) {
        if let error = error {
            TAOverlay.setOverlayLabelFont(UIFont(name: Appearance.Font.name, size:14)!)
            if autoHide {
                TAOverlay.showOverlayWithLabel(error.localizedDescription, options: .OverlaySizeRoundedRect | .OverlayTypeError | .OverlayTypeText | .OverlayDismissTap | .AutoHide)
            } else {
                TAOverlay.showOverlayWithLabel(error.localizedDescription, options: .OverlaySizeRoundedRect | .OverlayTypeError | .OverlayTypeText | .OverlayDismissTap)
            }
        } else {
            TAOverlay.showOverlayWithLabel(nil, options: .OverlaySizeRoundedRect | .OverlayTypeError | .AllowUserInteraction | .AutoHide)
        }
    }

    func success(message: String) {
        TAOverlay.showOverlayWithLabel(nil, options: .OverlaySizeRoundedRect | .OverlayTypeSuccess | .AllowUserInteraction | .AutoHide)
    }
}
