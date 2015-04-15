//
//  Alert.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/13.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import TAOverlay
import XCGLogger

class Alert {

    class func info(message: String, autoHide: Bool = true) {
        sharedInstance.info(message, autoHide: autoHide)
    }

    class func error(error: NSError?, autoHide: Bool = true) {
        sharedInstance.error(error, autoHide: autoHide)
    }

    class func success(message: String, autoHide: Bool = true) {
        sharedInstance.success(message, autoHide: autoHide)
    }

    let logger = XCGLogger.defaultInstance()

    static var sharedInstance = Alert()

    func configure() {
    }

    func info(message: String, autoHide: Bool = true) {
        let options: TAOverlayOptions
        if autoHide {
            options = .OverlaySizeRoundedRect | .OverlayTypeInfo | .OverlayTypeText | .OverlayDismissTap | .AutoHide
        } else {
            options = .OverlaySizeRoundedRect | .OverlayTypeInfo | .OverlayTypeText | .OverlayDismissTap
        }
        TAOverlay.showOverlayWithLabel(message, options: options)
    }

    func error(error: NSError?, autoHide: Bool = true) {
        let options: TAOverlayOptions
        if autoHide {
            options = .OverlaySizeRoundedRect | .OverlayTypeError | .OverlayTypeText | .OverlayDismissTap | .AutoHide
        } else {
            options = .OverlaySizeRoundedRect | .OverlayTypeError | .OverlayTypeText | .OverlayDismissTap
        }
        if let error = error {
            TAOverlay.showOverlayWithLabel(error.localizedDescription, options: options)
        } else {
            TAOverlay.showOverlayWithLabel(nil, options: options)
        }
    }

    func success(message: String, autoHide: Bool = true) {
        let options: TAOverlayOptions
        if autoHide {
            options = .OverlaySizeRoundedRect | .OverlayTypeSuccess | .OverlayDismissTap | .AutoHide
        } else {
            options = .OverlaySizeRoundedRect | .OverlayTypeSuccess | .OverlayDismissTap
        }
        TAOverlay.showOverlayWithLabel(message, options: options)
    }

}
