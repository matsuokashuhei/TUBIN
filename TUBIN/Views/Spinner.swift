//
//  Indicator.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/03.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import PKHUD
import TAOverlay

class Spinner {

    class func show() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        //sharedInstance.show()
    }

    class func dismiss() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        //sharedInstance.dissmiss()
    }

    class var sharedInstance: Spinner {
        struct Singleton {
            static let instance = Spinner()
        }
        return Singleton.instance
    }

    func configure() {
        // PKHUD
        PKHUD.sharedHUD.dimsBackground = false
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
//        HUDController.sharedController.dimsBackground = false
//        HUDController.sharedController.userInteractionOnUnderlyingViewsEnabled = false
    }

    func show() {
        configure()
        // PKHUD
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        //HUDController.sharedController.contentView = HUDContentView.SystemActivityIndicatorView()
        //HUDController.sharedController.show()
    }

    func dissmiss() {
        // PKHUD
        configure()
        PKHUD.sharedHUD.hide(animated: true)
        //HUDController.sharedController.hide()
    }

}