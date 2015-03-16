//
//  AppDelegate.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/06.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import BigBrother

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let logger = XCGLogger.defaultInstance()

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // ロガー
        XCGLogger.defaultInstance().setup(logLevel: .Info, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        // 外観
        let fontName = UIFont(name: "AvenirNext-Regular", size: 15.0)!
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: fontName]
        // Parse
        Parser.configure()
        // ネットワーク・インジケーター
        BigBrother.addToSharedSession()
        // TODO: AppDelegateを綺麗に保つ4つのテクニック http://qiita.com/nori0620/items/66ebc623f63fc3f0ca20 を読んでコードを整えること。
        return true
    }

    override func remoteControlReceivedWithEvent(event: UIEvent) {
        logger.debug("event: \(event)")
        VideoPlayer.sharedInstance.remoteControlReceivedWithEvent(event)
    }

}

