//
//  VideoPlayerViewController.swift
//  YouTubeApp
//
//  Created by matsuosh on 2014/12/20.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation
import YouTubeKit
import SVProgressHUD

class VideoPlayerViewController: UIViewController {
    
    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var videoPlayerView: VideoPlayerView! {
        didSet {
            videoPlayerView.delegate = self
        }
    }

    var showChannel: Bool = true
    @IBOutlet var channelView: UIView! {
        didSet {
            channelView.hidden = !showChannel
        }
    }

    enum PlayingVideo {
        case New, NowPlaying
    }
    var playingVideo: PlayingVideo = .New

    override func viewDidLoad() {
        // Notification
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: UIDevice.currentDevice())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidPrepareToPlay:", name: VideoPlayerDidPrepareToPlayNotification, object: nil)
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        // Navigation bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        configure(navigationItem: navigationItem)
        // Notification to Mini player
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        // Play video
        if playingVideo == PlayingVideo.New {
            startPlaying()
        } else {
            play()
        }
        let video = VideoPlayer.sharedInstance.playlist.playingVideo()
        setChannel(video)
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        // Notification to Mini player
        NSNotificationCenter.defaultCenter().postNotificationName(ShowMiniPlayerNotification, object: self)
        super.viewDidDisappear(animated)
    }

    // MARK: - Configurations

    func configure(#navigationItem: UINavigationItem) {
        let video = VideoPlayer.sharedInstance.playlist.playingVideo()
        navigationItem.title = video.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addVideoToFavorite")
        navigationItem.rightBarButtonItem = addButton
    }

    // MARK: Player controls

    func startPlaying() {
        videoPlayerView.startPlaying()
    }

    func play() {
        videoPlayerView.play()
    }

    // MARK: Actions
    func addVideoToFavorite() {
        let video = VideoPlayer.sharedInstance.playlist.playingVideo()
        Favorite.add(video) { (result) in
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToFavoritesNotification, object: self, userInfo: ["item": video]))
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
    }

}

extension VideoPlayerViewController {

    // MARK: - Notifications

    func orientationChanged(notification: NSNotification) {
        let device = notification.object as UIDevice
        switch device.orientation {
        case .Portrait, .PortraitUpsideDown:
            showOnlyVideo(false)
        default:
            break
        }
    }

    func videoPlayerDidPrepareToPlay(notification: NSNotification) {
        let video = VideoPlayer.sharedInstance.playlist.playingVideo()
        navigationItem.title = video.title
        setChannel(video)
    }

    func setChannel(video: Video) {
        if let channelsViewController = childViewControllers[0] as? ChannelsViewController {
            //channelsViewController.searchItems(parameters: ["channelId": video.channelId])
            channelsViewController.search(parameters: ["channelId": video.channelId])
        }
    }

}

extension VideoPlayerViewController: VideoPlayerViewDelegate {

    func playNextVideo() {
    }

    func playPrevVideo() {
    }

    func showOnlyVideo(showable: Bool) {
        navigationController?.setNavigationBarHidden(showable, animated: false)
    }
}