//
//  YouTubePlayerViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import MediaPlayer
import YouTubeKit

class YouTubePlayerViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var videoView: UIView!
    @IBOutlet var scrubberView: ScrubberView! {
        didSet {
            scrubberView.delegate = self
        }
    }
    @IBOutlet var previousButton: UIButton! {
        didSet {
            previousButton.addTarget(self, action: "previousButtonTapped:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: "playButtonTapped:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.addTarget(self, action: "nextButtonTapped:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet var channelView: UIView!

    var player = YouTubePlayer.sharedInstance

    var video: Video!
    var playlist: [Video]!

    let navigatable = true

    override func viewDidLoad() {
        logger.debug("")
        super.viewDidLoad()

        // Device orientation
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)

        switch UIDevice.currentDevice().orientation {
        case .Portrait, .PortraitUpsideDown:
            edgesForExtendedLayout = UIRectEdge.None
        default:
            edgesForExtendedLayout = UIRectEdge.Top
        }

        player.nowPlaying = video
        player.playlist = playlist

        configure(channelView: channelView)
    }

    override func viewWillLayoutSubviews() {
        logger.debug("")
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
    }

    override func viewWillAppear(animated: Bool) {
        logger.debug("")
        // Navigation
        navigationController?.setNavigationBarHidden(!navigatable, animated: true)
        configure(navigationItem: navigationItem)
        // YouTube player
        player.delegate = self
        if player.isPlaying() && player.nowPlaying.id == video.id {
            scrubberView.sync(player.controller)
            configure(player.controller)
            playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
        } else {
            player.nowPlaying = video
            playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Disabled)
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        player.delegate = nil
    }

    override func viewDidDisappear(animated: Bool) {
        logger.debug("")
        // Notification to Mini player
        NSNotificationCenter.defaultCenter().postNotificationName(ShowMiniPlayerNotification, object: self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = video.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        Favorite.exists(video) { (result) in
            switch result {
            case .Success(let box):
                if box.unbox {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                } else {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                }
            case .Failure(let box):
                let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                self.navigationItem.rightBarButtonItem = favoriteButton
            }
        }
    }

    func configure(#channelView: UIView) {
        let controller = ChannelsViewController(nibName: "ChannelsViewController", bundle: NSBundle.mainBundle())
        controller.search(parameters: ["channelId": video.channelId])
        controller.navigatable = navigatable
        controller.view.frame = channelView.bounds
        addChildViewController(controller)
        channelView.addSubview(controller.view)
    }
    // MARK: - Actions

    func playButtonTapped(button: UIButton) {
        if player.isPlaying() {
            pause()
        } else {
            play()
        }
    }

    func previousButtonTapped(button: UIButton) {
        if player.isPlaying() {
            logger.debug("player.controller.currentPlaybackTime: \(player.controller.currentPlaybackTime)")
            if player.controller.currentPlaybackTime < 3 {
                if let video = player.previousVideo() {
                    player.nowPlaying = video
                }
            } else {
                player.seekToTime(0)
            }
        }
    }

    func nextButtonTapped(button: UIButton) {
        if let video = player.nextVideo() {
            player.nowPlaying = video
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func configure(controller: MPMoviePlayerController) {
        if videoView.subviews.count > 0 {
            (videoView.subviews as NSArray).enumerateObjectsUsingBlock { (object, index, stop) in
                if let subview = object as? UIView {
                    subview.removeFromSuperview()
                }
            }
        }
        videoView.addSubview(controller.view)
        controller.view.frame = videoView.bounds
        controller.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        videoView.addConstraints([
            NSLayoutConstraint(item: controller.view, attribute: .Top, relatedBy: .Equal, toItem: videoView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Leading, relatedBy: .Equal, toItem: videoView, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Bottom, relatedBy: .Equal, toItem: videoView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Trailing, relatedBy: .Equal, toItem: videoView, attribute: .Trailing, multiplier: 1, constant: 0),
        ])
    }


    // MARK: Actions

    func addVideoToFavorite() {

        //navigationItem.rightBarButtonItem?.enabled = true
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        indicator.color = view.tintColor
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)

        Favorite.add(video) { (result) in
            indicator.stopAnimating()
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToFavoritesNotification, object: self, userInfo: ["item": self.video]))
                Async.main {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                }
            case .Failure(let box):
                let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                self.navigationItem.rightBarButtonItem = favoriteButton
                Alert.error(box.unbox)
            }
        }
    }

    func removeFromFavorite() {
        navigationItem.rightBarButtonItem?.enabled = true
        Favorite.remove(video) { (result) in
            self.navigationItem.rightBarButtonItem?.enabled = false
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ReloadFavoritesNotification, object: self))
                Async.main {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                }
            case .Failure(let box):
                Alert.error(box.unbox)
            }
        }
    }
}

extension YouTubePlayerViewController: YouTubePlayerDelegate {

    func durationAvailable(controller: MPMoviePlayerController) {
        logger.debug("controller.duration: \(controller.duration)")
        video = player.nowPlaying
        configure(navigationItem: navigationItem)
        scrubberView.configure(controller.duration)
    }

    func readyForDisplay(controller: MPMoviePlayerController) {
        logger.debug("")
    }

    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController) {
        logger.debug("")
        configure(controller)
        play()
    }

    func playingAtTime(controller: MPMoviePlayerController) {
        scrubberView.setTime(controller.currentPlaybackTime, duration: controller.duration)
    }

    func playbackDidFinish(controller: MPMoviePlayerController) {
        logger.debug("")
    }

    func playBackStateDidChange(controller: MPMoviePlayerController) {
        switch controller.playbackState {
        case .Playing:
            logger.debug("Playing")
            playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
        case .Paused, .Stopped:
            logger.debug("Paused, Stopped")
            playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Normal)
        default:
            logger.debug("\(controller.playbackState.rawValue)")
            break
        }
    }

}

extension YouTubePlayerViewController: ScrubberViewDelegate {

    func beginSeek(slider: UISlider) {
        player.pause()
    }

    func seekPositionChanged(slider: UISlider) {
        seekToSeconds(slider.value)
    }

    func endSeek(slider: UISlider) {
        player.play()
    }

    func seekToSeconds(seconds: Float) {
        player.seekToTime(seconds)
    }

}

extension YouTubePlayerViewController {

    func orientationChanged(notification: NSNotification) {
        // http://program.station.ez-net.jp/special/handbook/objective-c/uidevice/orientation.asp
        let device = notification.object as UIDevice
        switch device.orientation {
        case .Portrait, .PortraitUpsideDown:
            logger.debug(".Portrait, .PortraitUpsideDown")
            edgesForExtendedLayout = UIRectEdge.Top
        case .LandscapeLeft, .LandscapeRight:
            logger.debug(".LandscapeLeft, .LandscapeRight")
            edgesForExtendedLayout = UIRectEdge.None
        default:
            break
        }
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

}