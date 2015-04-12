//
//  Indicator.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/03.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import TAOverlay

class Spinner {

    class func show(options: [String: AnyObject] = ["allowUserInteraction": true]) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        sharedInstance.show(options: options)
    }

    class func dismiss() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        sharedInstance.dissmiss()
    }

    static var sharedInstance = Spinner()

    func configure() {
    }

    func show(options: [String: AnyObject] = [:]) {
        let overlayOptions: TAOverlayOptions
        if let allowUserInteraction = options["allowUserInteraction"] as? Bool {
            if allowUserInteraction {
                overlayOptions = .AllowUserInteraction | .OverlayTypeActivityDefault | .OverlaySizeRoundedRect
            } else {
                overlayOptions = .OverlayTypeActivityDefault | .OverlaySizeRoundedRect
            }
        } else {
            overlayOptions = .OverlayTypeActivityDefault | .OverlaySizeRoundedRect
        }
        TAOverlay.showOverlayWithLabel(nil, options: overlayOptions)
    }

    func dissmiss() {
        TAOverlay.hideOverlay()
    }

}