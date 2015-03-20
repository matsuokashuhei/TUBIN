//
//  Indicator.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/03.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import SVProgressHUD

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
        // SVProgressHUD
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.setForegroundColor(UIColor.redColor())
        SVProgressHUD.setRingThickness(4)
        SVProgressHUD.setFont(UIFont(name: "AvenirNext-Regular", size: 15.0)!)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Clear)
    }

    func show() {
        configure()
        SVProgressHUD.show()
    }

    func dissmiss() {
        configure()
        SVProgressHUD.dismiss()
    }

}