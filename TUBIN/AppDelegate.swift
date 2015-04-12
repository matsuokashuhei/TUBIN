//
//  AppDelegate.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/06.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let logger = XCGLogger.defaultInstance()

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // ロガー
        XCGLogger.defaultInstance().setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)

        // Fabric
        Fabric.with([Crashlytics()])

        // Parse
        Parser.configure()

        // Settings
        if !Defaults.hasKey("launched") {
            Defaults["launched"] = true
            Defaults["upgraded"] = false
            Defaults["maxNumberOfHistories"] = 100
            Defaults["theme"] = "Light"
        }

        if Defaults["theme"].string == "Light" {
            Appearance.apply(.Light)
        } else {
            Appearance.apply(.Dark)
        }
        // TODO: AppDelegateを綺麗に保つ4つのテクニック http://qiita.com/nori0620/items/66ebc623f63fc3f0ca20 を読んでコードを整えること。
        return true
    }

}

