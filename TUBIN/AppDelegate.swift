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
            Defaults["maxNumberOfHistories"] = 15
            Defaults["maxNumberOfFavorites"] = 30
            // Subscribes + 4 (Popular, Favorites, Search)
            Defaults["maxNumberOfSubscribes"] = 13
            Defaults["theme"] = "Light"
        }

        let launched = Defaults["launched"].bool!
        logger.verbose("launced: \(launched)")
        let upgraded = Defaults["upgraded"].bool!
        logger.verbose("upgraded: \(upgraded)")
        let maxNumberOfHistories = Defaults["maxNumberOfHistories"].int!
        logger.verbose("maxNumberOfHistories: \(maxNumberOfHistories)")
        let maxNumberOfFavorites = Defaults["maxNumberOfFavorites"].int!
        logger.verbose("maxNumberOfFavorites: \(maxNumberOfFavorites)")
        let maxNumberOfSubscribes = Defaults["maxNumberOfSubscribes"].int!
        logger.verbose("maxNumberOfSubscribes: \(maxNumberOfSubscribes)")

        if Defaults["theme"].string == "Light" {
            Appearance.apply(.Light)
        } else {
            Appearance.apply(.Dark)
        }
        // TODO: AppDelegateを綺麗に保つ4つのテクニック http://qiita.com/nori0620/items/66ebc623f63fc3f0ca20 を読んでコードを整えること。
        return true
    }

}

