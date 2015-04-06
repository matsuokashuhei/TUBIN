//
//  Indicator.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/03.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import TAOverlay

class Spinner {

    class func show() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        sharedInstance.show()
    }

    class func dismiss() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        sharedInstance.dissmiss()
    }

    class var sharedInstance: Spinner {
        struct Singleton {
            static let instance = Spinner()
        }
        return Singleton.instance
    }

    func configure() {
    }

    func show() {
        TAOverlay.showOverlayWithLabel(nil, options: .AllowUserInteraction | .OverlayTypeActivityDefault | .OverlaySizeRoundedRect)
    }

    func dissmiss() {
        TAOverlay.hideOverlay()
    }

}