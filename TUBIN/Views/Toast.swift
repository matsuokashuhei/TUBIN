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

    /*
    class func show(#item: Item) {
        sharedInstance.show(item: item)
    }

    class func show() {
        sharedInstance.show()
    }
    */

    class func addToFavorites(#video: Video) {
        sharedInstance.addToFavorites(video: video)
    }

    class func addToBookmarks(#item: Item) {
        sharedInstance.addToBookmarks(item: item)
    }

    static var sharedInstance = Toast()

    init() {
        let options: [String: AnyObject] = [
            kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
            kCRToastTextColorKey: Appearance.sharedInstance.theme.lightColor,
            kCRToastBackgroundColorKey: Appearance.sharedInstance.theme.primaryColor,
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

    func addToBookmarks(#item: Item) {
        let options:[String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
            kCRToastTextKey: NSLocalizedString("Added to bookmarks!", comment: "Added to bookmarks!")
            ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }

    func addToFavorites(#video: Video) {
        let options:[String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
            kCRToastTextKey: NSLocalizedString("Added to favorites!", comment: "Added to favorites")
            ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }

    /*
    func show() {
        let options:[String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
            kCRToastTextKey: NSLocalizedString("bookmarked!", comment: "プレイリストやチャンネルをブックマークしたときに通知するメッセージ")
            ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }

    func show(#item: Item) {
        let options:[String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
            kCRToastTextKey: NSLocalizedString("bookmarked!", comment: "プレイリストやチャンネルをブックマークしたときに通知するメッセージ")
            ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }
    */

}