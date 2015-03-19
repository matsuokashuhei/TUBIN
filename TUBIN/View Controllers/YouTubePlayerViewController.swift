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

        player.nowPlaying = video
        player.playlist = playlist

        configure(channelView: channelView)

        // Auto layout
        edgesForExtendedLayout = UIRectEdge.None
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
                edgesForExtendedLayout = UIRectEdge.Top
            }
        }

        super.viewDidLoad()
    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        configure(UIDevice.currentDevice().orientation)
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    }

    override func viewDidLayoutSubviews() {
        logger.debug("")
    }

    override func viewWillAppear(animated: Bool) {
        logger.debug("")
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        // Navigation
        navigationController?.setNavigationBarHidden(!navigatable, animated: true)
        configure(navigationItem: navigationItem)
        // Trait
        configure(UIDevice.currentDevice().orientation)
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
        showPlayerController()
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
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            let recognizer = UITapGestureRecognizer(target: self, action: "videoViewTapped")
            recognizer.delegate = self
            controller.view.gestureRecognizers?.removeAll(keepCapacity: true)
            controller.view.addGestureRecognizer(recognizer)
        }
    }

    func configure(orientation: UIDeviceOrientation) {
        edgesForExtendedLayout = UIRectEdge.None
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            // iPhone
            if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
                // Portait
                showPlayerController()
            } else {
                edgesForExtendedLayout = UIRectEdge.Top
            }
        }
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
        hidePlayerController()
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
            if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
                return
            }
            if self.player.isPlaying() == false {
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

// MARK: - ScrubberViewDelegate
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

// MARK: - Parse
extension YouTubePlayerViewController {

    func addVideoToFavorite() {

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