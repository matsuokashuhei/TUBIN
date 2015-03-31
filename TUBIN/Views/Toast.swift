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

    class func bookmark(#item: Item) {
        sharedInstance.bookmark(item: item)
    }

    class func favorite(#item: Item) {
        sharedInstance.favorite(item: item)
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

    func bookmark(#item: Item) {
        let options: [String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.StatusBar.rawValue,
            kCRToastTextKey: "subscribed!",
        ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
        /*
        if let URL = NSURL(string: item.thumbnailURL) {
        SDWebImageManager.sharedManager().downloadImageWithURL(URL, options: SDWebImageOptions.RetryFailed, progress: { (_, _) -> Void in
        }, completed: { (image, error, SDImageCacheTypeDisk, finished, URL) -> Void in
            if let image = image {
            let options: [String: AnyObject] = [
                kCRToastTextKey: item.title,
                kCRToastImageKey: image,
            ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
            }
        })
        }
        */
    }

    func favorite(#item: Item) {
        let options: [String: AnyObject] = [
            kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
            kCRToastTextKey: item.title,
            kCRToastSubtitleTextKey: "favorited!"
        ]
        CRToastManager.showNotificationWithOptions(options, completionBlock: nil)
    }

}