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
import Async
import SwiftyUserDefaults

class YouTubePlayerViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.hidden = true
        }
    }
    @IBOutlet weak var scrubberView: ScrubberView! {
        didSet {
            scrubberView.delegate = self
        }
    }
    @IBOutlet weak var previousButton: UIButton! {
        didSet {
            previousButton.addTarget(self, action: "previousButtonTapped:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: "playButtonTapped:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.addTarget(self, action: "nextButtonTapped:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var channelView: ChannelView!

    var player = YouTubePlayer.sharedInstance

    var channel: Channel?
    var video: Video!
    var playlist: [Video]!

    let navigatable = true

    convenience init(device: UIDevice) {
        if device.userInterfaceIdiom == .Phone {
            self.init(nibName: "YouTubePlayerViewController_Phone", bundle: NSBundle.mainBundle())
        } else {
            self.init(nibName: "YouTubePlayerViewController_Pad", bundle: NSBundle.mainBundle())
        }
    }

    override func viewDidLoad() {

        player.delegate = self

        player.nowPlaying = video
        player.playlist = playlist

        configure(channelView: channelView)

        super.viewDidLoad()
    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        _configure(UIDevice.currentDevice().orientation)
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        // Navigation
        configure(navigationItem: navigationItem)
        // Orientation
        configure(UIApplication.sharedApplication().statusBarOrientation)
        // YouTube player
        player.delegate = self
        if player.controller.playbackState == .Playing {
            if video.id == player.nowPlaying.id {
                scrubberView.sync(player.controller)
                addPlayerView(player.controller)
            } else {
                player.nowPlaying = video
                playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Disabled)
            }
        }
        playBackStateDidChange(player.controller)
        showPlayerController()
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        player.delegate = nil
        player.controller.view.gestureRecognizers?.removeAll(keepCapacity: true)
        showAds()
    }

    override func viewDidDisappear(animated: Bool) {
        // Notification to Mini player
        NSNotificationCenter.defaultCenter().postNotificationName(ShowMiniPlayerNotification, object: self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#navigationItem: UINavigationItem) {
        // Navigation bar
        navigationController?.setNavigationBarHidden(!navigatable, animated: true)
        // Navigation item
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

    func configure(#channelView: ChannelView) {
        if let channel = channel {
            if channel.id == video.channelId {
                channelView.height.constant = 0
                return
            }
        }
        (channelView.subviews as NSArray).enumerateObjectsUsingBlock { (object, index, stop) in
            if let subview = object as? UIView {
                subview.removeFromSuperview()
           }
        }
        (childViewControllers as NSArray).enumerateObjectsUsingBlock { (object, index, stop) in
            if let controller = object as? ChannelViewController {
                controller.removeFromParentViewController()
            }
        }
        let controller = ChannelsViewController()
        controller.navigatable = navigatable
        controller.parameters = ["channelId": video.channelId]
        controller.spinnable = false
        controller.search()
        //controller.search(parameters: ["channelId": video.channelId])
        controller.view.frame = channelView.bounds
        addChildViewController(controller)
        channelView.addSubview(controller.view)
    }

    func addPlayerView(controller: MPMoviePlayerController) {
        removePlayerView(videoView)
        videoView.addSubview(controller.view)
        controller.view.frame = videoView.bounds
        controller.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        videoView.addConstraints([
            NSLayoutConstraint(item: controller.view, attribute: .Top, relatedBy: .Equal, toItem: videoView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Leading, relatedBy: .Equal, toItem: videoView, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Bottom, relatedBy: .Equal, toItem: videoView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Trailing, relatedBy: .Equal, toItem: videoView, attribute: .Trailing, multiplier: 1, constant: 0),
        ])
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            let recognizer = UITapGestureRecognizer(target: self, action: "videoViewTapped")
            recognizer.delegate = self
            controller.view.gestureRecognizers?.removeAll(keepCapacity: true)
            controller.view.addGestureRecognizer(recognizer)
        }
    }

    func removePlayerView(videoView: UIView) {
        for view in videoView.subviews {
            if let view = view as? UIActivityIndicatorView {
                continue
            }
            if let view = view as? UIView {
                view.removeFromSuperview()
            }
        }
    }

    func configure(orientation: UIInterfaceOrientation) {
        edgesForExtendedLayout = UIRectEdge.None
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            if UIInterfaceOrientationIsPortrait(orientation) {
                showPlayerController()
                showAds()
            }
            if UIInterfaceOrientationIsLandscape(orientation) {
                edgesForExtendedLayout = UIRectEdge.Top
                hideAds()
            }
        }
    }

    func _configure(orientation: UIDeviceOrientation) {
        edgesForExtendedLayout = UIRectEdge.None
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            // iPhone
            if UIDeviceOrientationIsPortrait(orientation) {
                // Portait
                showPlayerController()
                showAds()
            }
            if UIDeviceOrientationIsLandscape(orientation) {
                edgesForExtendedLayout = UIRectEdge.Top
                hideAds()
            }
        }
    }

    func hideAds() {
        if let upgraded = Defaults["upgraded"].bool {
            if !upgraded {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AdBannerShowableNotification, object: self, userInfo: ["showable": false]))
            }
        }
    }

    func showAds() {
        if let upgraded = Defaults["upgraded"].bool {
            if !upgraded {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AdBannerShowableNotification, object: self, userInfo: ["showable": true]))
            }
        }
    }

    // MARK: - Actions

    func playButtonTapped(button: UIButton) {
        if player.controller.playbackState == .Playing {
            pause()
        } else {
            play()
        }
    }

    func previousButtonTapped(button: UIButton) {
        if player.controller.playbackState == .Playing {
            if player.controller.currentPlaybackTime < 3 {
                if let video = player.previousVideo() {
                    removePlayerView(videoView)
                    player.nowPlaying = video
                }
            } else {
                player.seekToTime(0)
            }
        } else {
            if let video = player.previousVideo() {
                removePlayerView(videoView)
                player.nowPlaying = video
            }
        }
    }

    func nextButtonTapped(button: UIButton) {
        if let video = player.nextVideo() {
            removePlayerView(videoView)
            player.nowPlaying = video
        }
    }

    func play() {
        player.play()
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            hidePlayerController()
        }
    }

    func pause() {
        player.pause()
    }

    func videoViewTapped() {
        if navigationController!.navigationBarHidden {
            showPlayerController()
        } else{
            hidePlayerController()
        }
    }

    func showPlayerController() {
        let alpha = CGFloat(1)
        navigationController?.navigationBar.alpha = alpha
        navigationController?.setNavigationBarHidden(false, animated: false)
        for view in [previousButton, playButton, nextButton, scrubberView] as [UIView] {
            view.alpha = alpha
            view.hidden = false
        }
        //hidePlayerController(delay: 3.0)
        /*
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            let delay = UInt64(3.0) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) { () in
                self.hidePlayerController()
            }
        }
        */
    }

    func hidePlayerController() {
        let delay = UInt64(0.5) * NSEC_PER_SEC
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) { () in
            if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
                return
            }
            if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
                return
            }
            if self.player.controller.playbackState != .Playing {
                return
            }
            let duration = 1.0
            let alpha = CGFloat(0)
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.navigationController?.navigationBar.alpha = alpha
                for view in [self.previousButton, self.playButton, self.nextButton, self.scrubberView] as [UIView] {
                    view.alpha = alpha
                }
            }) { (finished) in
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                for view in [self.previousButton, self.playButton, self.nextButton, self.scrubberView] as [UIView] {
                    view.hidden = true
                }
            }
        }
    }

}

// MARK: - UIGestureRecognizerDelegate
extension YouTubePlayerViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

// MARK: - YouTubePlayerDelegate
extension YouTubePlayerViewController: YouTubePlayerDelegate {

    func prepareToPlay(video: Video) {
        self.video = video
        configure(navigationItem: navigationItem)
        configure(channelView: channelView)
        loadingIndicator.bringSubviewToFront(videoView)
        loadingIndicator.hidden = false
        loadingIndicator.startAnimating()
    }

    func durationAvailable(controller: MPMoviePlayerController) {
        scrubberView._configure(controller.duration)
        loadingIndicator.stopAnimating()
        loadingIndicator.hidden = true
        loadingIndicator.sendSubviewToBack(videoView)
    }

    func readyForDisplay(controller: MPMoviePlayerController) {
    }

    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController) {
        addPlayerView(controller)
        play()
        History.add(video) { (result) in
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "WatchVideoNotification", object: self))
            case .Failure(let box):
                let error = box.unbox
                self.logger.error(error.localizedDescription)
                Alert.error(box.unbox)
            }
        }
    }

    func playingAtTime(controller: MPMoviePlayerController) {
        scrubberView.__setTime(controller.currentPlaybackTime, duration: controller.duration)
    }

    func playbackDidFinish(controller: MPMoviePlayerController) {
    }

    func playBackStateDidChange(controller: MPMoviePlayerController) {
        switch controller.playbackState {
        case .Playing:
            playButton.setImage(UIImage(named: "ic_pause_circle_outline_96px"), forState: .Normal)
        case .Paused, .Stopped:
            playButton.setImage(UIImage(named: "ic_play_circle_outline_96px"), forState: .Normal)
        default:
            break
        }
    }

}

// MARK: - ScrubberViewDelegate
extension YouTubePlayerViewController: ScrubberViewDelegate {

    func beginSeek(slider: UISlider) {
        pause()
    }

    func seekPositionChanged(slider: UISlider) {
        seekToSeconds(slider.value)
    }

    func endSeek(slider: UISlider) {
        play()
    }

    func seekToSeconds(seconds: Float) {
        player.seekToTime(seconds)
    }

}

// MARK: - Parse
extension YouTubePlayerViewController {

    func addVideoToFavorite() {

        Favorite.count { (result)in
            switch result {
            case .Success(let box):
                let count = box.unbox
                if count < Defaults["maxNumberOfFavorites"].int! {
                    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
                    indicator.startAnimating()
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)

                    Favorite.add(self.video) { (result) in
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
                            let error = box.unbox
                            self.logger.error(error.localizedDescription)
                            Alert.error(box.unbox)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: nil, message: NSLocalizedString("Cannot add to favorites", comment: "Cannot add to favorites"), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismis", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            case .Failure(let box):
                let error = box.unbox
                self.logger.error(error.localizedDescription)
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
                let error = box.unbox
                self.logger.error(error.localizedDescription)
                Alert.error(box.unbox)
            }
        }
    }
}