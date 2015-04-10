//
//  RootViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import iAd
import YouTubeKit
import SwiftyUserDefaults

class RootViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var miniPlayerView: MiniPlayerView! {
        didSet {
            miniPlayerView.delegate = self
            miniPlayerView.hide()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMiniPlayer:", name: ShowMiniPlayerNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideMiniPlayer:", name: HideMiniPlayerNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "upgradeApp:", name: UpgradeAppNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "restoreApp:", name: RestoreAppNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveAdBannerShowableNoficication:", name: AdBannerShowableNotification, object: nil)
        }
    }

    override func viewDidLoad() {
        if let upgraded = Defaults["upgraded"].bool {
            if upgraded {
                canDisplayBannerAds = false
            } else {
                canDisplayBannerAds = true
            }
        }
        super.viewDidLoad()
    }

    func didReceiveAdBannerShowableNoficication(notification: NSNotification) {
        if let upgraded = Defaults["upgraded"].bool {
            if upgraded {
                return
            }
        }
        if let userInfo = notification.userInfo {
            if let showable = userInfo["showable"] as? Bool {
                canDisplayBannerAds = showable
            }
        }
    }

    func upgradeApp(notification: NSNotification) {
        Defaults["upgraded"] = true
        //Defaults["maxNumberOfHistories"] = 999
        Defaults["maxNumberOfFavorites"] = Int.max
        Defaults["maxNumberOfSubscribes"] = Int.max
        canDisplayBannerAds = false
    }

    func restoreApp(notification: NSNotification) {
        Alert.success("Restored App")
        upgradeApp(notification)
    }

    func showMiniPlayer(notification: NSNotification) {
        let playbackState = YouTubePlayer.sharedInstance.controller.playbackState
        if playbackState == .Paused || playbackState == .Stopped {
            return
        }
        miniPlayerView.show()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func hideMiniPlayer(notification: NSNotification) {
        miniPlayerView.hide()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

}

extension RootViewController: MiniPlayerViewDelegate {

    func backToVideoPlayerViewController() {
        if let navigationController = childViewControllers.first as? UINavigationController {
            let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
            controller.video = YouTubePlayer.sharedInstance.nowPlaying
            controller.playlist = YouTubePlayer.sharedInstance.playlist
            navigationController.pushViewController(controller, animated: true)
        }
    }

}

extension RootViewController: ADBannerViewDelegate {

    func bannerViewDidLoadAd(banner: ADBannerView!) {
        logger.debug("")
    }

    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        logger.debug("")
    }

}