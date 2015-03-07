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

    //let videoPlayer = VideoPlayer.sharedInstance

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
        super.viewDidLoad()
        canDisplayBannerAds = true
    }

    func showMiniPlayer(notification: NSNotification) {
        miniPlayerView.show()
    }

    func hideMiniPlayer(notification: NSNotification) {
        miniPlayerView.hide()
    }

    func setBannerShowable(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let showable = userInfo["showable"] as? Bool {
                canDisplayBannerAds = showable
            }
        }
    }

}

extension RootViewController: MiniPlayerViewDelegate {

    func backToVideoPlayerViewController(video: Video) {
        /*
        if let navigationController = childViewControllers.first as? UINavigationController {
            let destinationViewController = videoPlayer.controller
            destinationViewController.playingVideo = .NowPlaying
            navigationController.pushViewController(destinationViewController, animated: true)
        }
        */
    }

}
