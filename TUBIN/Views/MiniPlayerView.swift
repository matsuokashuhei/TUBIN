//
//  MiniPlayerView.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import UIKit
import MediaPlayer
import YouTubeKit
import XCGLogger

protocol MiniPlayerViewDelegate {
    func backToVideoPlayerViewController()
}

class MiniPlayerView: UIView {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var videoView: VideoView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.hidden = true
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
    @IBOutlet var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: "backToVideoPlayerViewController", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var removeButton: UIButton! {
        didSet {
            removeButton.addTarget(self, action: "removeButtonTapped:", forControlEvents: .TouchUpInside)
            removeButton.hidden = true
        }
    }
    @IBOutlet var height: NSLayoutConstraint!

    var player = YouTubePlayer.sharedInstance

    var delegate: MiniPlayerViewDelegate?

    func show() {
        player.delegate = self
        playBackStateDidChange(player.controller)
        height.constant = 88
        hidden = false
        addPlayerView(player.controller)
        //removeButton.hidden = true
    }

    func hide() {
        height.constant = 0
        hidden = true
    }

    func playButtonTapped(button: UIButton) {
        if player.controller.playbackState == .Playing {
            player.pause()
            //removeButton.hidden = false
        } else {
            player.play()
            //removeButton.hidden = true
        }
    }

    func previousButtonTapped(button: UIButton) {
        removePlayerView(videoView)
        player.playPreviousVideo()
    }

    func nextButtonTapped(button: UIButton) {
        removePlayerView(videoView)
        player.playNextVideo()
    }

    func removeButtonTapped(button: UIButton) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0.0
        }) { (completion) -> Void in
            self.height.constant = 0
            self.hidden = true
            self.alpha = 1.0
        }
        //hide()
    }

    func backToVideoPlayerViewController() {
        hide()
        delegate?.backToVideoPlayerViewController()
    }

    func addPlayerView(controller: MPMoviePlayerController) {
        removePlayerView(videoView)
        videoView.addSubview(controller.view)
        controller.view.frame = videoView.bounds
        videoView.addConstraints([
            NSLayoutConstraint(item: controller.view, attribute: .Top, relatedBy: .Equal, toItem: videoView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Leading, relatedBy: .Equal, toItem: videoView, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Bottom, relatedBy: .Equal, toItem: videoView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: controller.view, attribute: .Trailing, relatedBy: .Equal, toItem: videoView, attribute: .Trailing, multiplier: 1, constant: 0),
        ])
    }

    func removePlayerView(videoView: UIView) {
        for view in videoView.subviews {
            if let _ = view as? UIActivityIndicatorView {
                continue
            }
            view.removeFromSuperview()
        }
        /*
        if videoView.subviews.count > 0 {
            (videoView.subviews as NSArray).enumerateObjectsUsingBlock { (object, index, stop) in
                if let subview = object as? UIView {
                    subview.removeFromSuperview()
                }
            }
        }
        */
    }

    func startLoading() {
        loadingIndicator.bringSubviewToFront(videoView)
        loadingIndicator.hidden = false
        loadingIndicator.startAnimating()
    }

    func stopLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.hidden = true
        loadingIndicator.sendSubviewToBack(videoView)
    }
}

extension MiniPlayerView: YouTubePlayerDelegate {

    func prepareToPlay(video: Video) {
        startLoading()
    }

    func playbackFailed(error: NSError) {
        stopLoading()
        Alert.error(error)
    }

    func durationAvailable(controller: MPMoviePlayerController) {
        stopLoading()
    }

    func readyForDisplay(controller: MPMoviePlayerController) {
    }

    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController) {
        addPlayerView(controller)
        player.play()
        History.create(player.nowPlaying)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "WatchVideoNotification", object: self))
    }

    func playingAtTime(controller: MPMoviePlayerController) {
    }

    func playbackDidFinish(controller: MPMoviePlayerController) {
    }

    func playBackStateDidChange(controller: MPMoviePlayerController) {
        switch controller.playbackState {
        case .Playing:
            playButton.setImage(UIImage(named: "ic_pause_circle_outline_48px"), forState: .Normal)
            removeButton.hidden = true
        case .Paused, .Stopped:
            playButton.setImage(UIImage(named: "ic_play_circle_outline_48px"), forState: .Normal)
            removeButton.hidden = false
        default:
            playButton.setImage(UIImage(named: "ic_play_circle_outline_48px"), forState: .Normal)
            removeButton.hidden = false
        }
    }
}
