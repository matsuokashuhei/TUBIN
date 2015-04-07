//
//  Toast.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/03.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import YouTubeKit
import CRToast

class Toast {

    class func show(#item: Item) {
        sharedInstance.show(item: item)
    }

    class var sharedInstance: Toast {
        struct Singleton {
            static let instance = Toast()
        }
        return Singleton.instance
    }

    init() {
        let options: [String: AnyObject] = [
            kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
            kCRToastBackgroundColorKey: UIColor.redColor(),
            kCRToastFontKey: UIFont(name: Appearance.Font.name, size: 14.0)!,
            kCRToastSubtitleFontKey: UIFont(name: Appearance.Font.name, size: 12.0)!,
            kCRToastNotificationPresentationTypeKey: CRToastPresentationType.Cover.rawValue,
            //kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            //kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
            kCRToastAnimationInTypeKey: CRToastAnimationType.Linear.rawValue,
            kCRToastAnimationOutTypeKey: CRToastAnimationType.Linear.rawValue,
            kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
            kCRToastTimeIntervalKey: NSTimeInterval(0.5)

        ]
        CRToastManager.setDefaultOptions(options)
    }

    func show(#item: Item) {
        let options: [String: AnyObject] = {
            if let video = item as? Video {
                return [
                    kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
                    kCRToastTextKey: item.title,
                    kCRToastSubtitleTextKey: NSLocalizedString("bookmarked!", comment: "ビデオをフェイバリットに保存したときに通知するメッセージ")
                ]
            } else {
                return [
                    kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
                    kCRToastTextKey: NSLocalizedString("bookmarked!", comment: "プレイリストやチャンネルをブックマークしたときに通知するメッセージ")
                ]
            }
        }()
        /*
        let options: [String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
            kCRToastTextKey: NSLocalizedString("bookmarked!", comment: "プレイリストやチャンネルをブックマークしたときに通知するメッセージ")
        ]
        */
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }

    /*
    func favorite(#item: Item) {
        let options: [String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            kCRToastTextKey: item.title,
            kCRToastSubtitleTextKey: NSLocalizedString("favorited!", comment: "ビデオをフェイバリットに保存したときに通知するメッセージ")
        ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
    */

}