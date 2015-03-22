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

class RootViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var miniPlayerView: MiniPlayerView! {
        didSet {
            miniPlayerView.delegate = self
            miniPlayerView.hide()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMiniPlayer:", name: ShowMiniPlayerNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideMiniPlayer:", name: HideMiniPlayerNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "setBannerShowable:", name: BannerShowableNotification, object: nil)
        }
    }

    override func viewDidLoad() {
        canDisplayBannerAds = true
        super.viewDidLoad()
    }

    func setBannerShowable(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let showable = userInfo["showable"] as? Bool {
                canDisplayBannerAds = showable
            }
        }
    }

    func showMiniPlayer(notification: NSNotification) {
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
            //let controller = YouTubePlayerViewController(nibName: "YouTubePlayerViewController", bundle: NSBundle.mainBundle())
            let controller: YouTubePlayerViewController = {
                if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                    return YouTubePlayerViewController(nibName: "YouTubePlayerViewController_Phone", bundle: NSBundle.mainBundle())
                } else {
                    return YouTubePlayerViewController(nibName: "YouTubePlayerViewController_Pad", bundle: NSBundle.mainBundle())
                }
            }()
            controller.video = YouTubePlayer.sharedInstance.nowPlaying
            controller.playlist = YouTubePlayer.sharedInstance.playlist
            navigationController.pushViewController(controller, animated: true)
        }
    }

}