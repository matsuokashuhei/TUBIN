//
//  AppDelegate.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/06.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Fabric
import Crashlytics
import SwiftyUserDefaults
import XCGLogger
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let logger = XCGLogger.defaultInstance()

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // ロガー
        XCGLogger.defaultInstance().setup(logLevel: .Info, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)

        // Fabric
        Fabric.with([Crashlytics()])

        // Parse
        //Parser.configure()

        // Settings
        if Defaults.hasKey("launched") {
            // 1.1以下のバージョンで起動したことがある場合
            if !Defaults.hasKey("migrated") {
                // DBをマイグレートしていない場合
                Parser.configure()
                Bookmark.setUp()
                Bookmark.migrate()
                Collection.migrate()
                Parser.goodbye()
                Defaults["migrated"] = true
            }
        } else {
            Bookmark.setUp()
            Collection.setUp()
            Defaults["launched"] = true
            Defaults["migrated"] = true
            Defaults["upgraded"] = false
            Defaults["maxNumberOfHistories"] = 100
            Defaults["theme"] = "Light"
        }

        if Defaults["theme"].string == "Light" {
            Appearance.apply(.Light)
        } else {
            Appearance.apply(.Dark)
        }

        // Realmのマイグレーション
//        setSchemaVersion(1, Realm.defaultPath) { (migration, oldSchemaVersion) -> () in
//        }
        // App Storeのスクリーンショットをとるとき
        //Defaults["upgraded"] = true
        // TODO: AppDelegateを綺麗に保つ4つのテクニック http://qiita.com/nori0620/items/66ebc623f63fc3f0ca20 を読んでコードを整えること。
        return true
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first as? UITouch {
            let location = touch.locationInView(window)
            if CGRectContainsPoint(UIApplication.sharedApplication().statusBarFrame, location) {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: StatusBarTouchedNotification, object: nil))
            }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        logger.debug("")
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }

    override func remoteControlReceivedWithEvent(event: UIEvent) {
        if event.type == .RemoteControl {
            let player = YouTubePlayer.sharedInstance
            switch event.subtype {
            case .RemoteControlPlay:
                player.play()
            case .RemoteControlPause:
                player.pause()
            case .RemoteControlNextTrack:
                player.playNextVideo()
            case .RemoteControlPreviousTrack:
                player.playPreviousVideo()
            default:
                break
            }
        }
    }
}

