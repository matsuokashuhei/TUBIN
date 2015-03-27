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

protocol MiniPlayerViewDelegate {
    func backToVideoPlayerViewController()
}

class MiniPlayerView: UIView {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var videoView: UIView!
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
    @IBOutlet var height: NSLayoutConstraint!

    var player = YouTubePlayer.sharedInstance

    var delegate: MiniPlayerViewDelegate?

    func show() {
        player.delegate = self
        playBackStateDidChange(player.controller)
        height.constant = 86
        hidden = false
        addPlayerView(player.controller)
    }

    func hide() {
        height.constant = 0
        hidden = true
    }

    func playButtonTapped(button: UIButton) {
        if player.controller.playbackState == .Playing {
            player.pause()
        } else {
            player.play()
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

    func backToVideoPlayerViewController() {
        hide()
        delegate?.backToVideoPlayerViewController()
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
        //controller.play()
    }

    func removePlayerView(videoView: UIView) {
        if videoView.subviews.count > 0 {
            (videoView.subviews as NSArray).enumerateObjectsUsingBlock { (object, index, stop) in
                if let subview = object as? UIView {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

extension MiniPlayerView: YouTubePlayerDelegate {

    func prepareToPlay(video: Video) {
    }

    func durationAvailable(controller: MPMoviePlayerController) {
        logger.debug("controller.duration: \(controller.duration)")
    }

    func readyForDisplay(controller: MPMoviePlayerController) {
        logger.debug("")
    }

    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController) {
        logger.debug("")
        addPlayerView(controller)
        player.play()
    }

    func playingAtTime(controller: MPMoviePlayerController) {
        logger.verbose("")
    }

    func playbackDidFinish(controller: MPMoviePlayerController) {
        logger.debug("")
    }

    func playBackStateDidChange(controller: MPMoviePlayerController) {
        switch controller.playbackState {
        case .Playing:
            logger.debug("Playing")
            playButton.setImage(UIImage(named: "ic_pause_circle_outline_48px"), forState: .Normal)
        case .Paused, .Stopped:
            logger.debug("Paused, Stopped")
            playButton.setImage(UIImage(named: "ic_play_circle_outline_48px"), forState: .Normal)
        default:
            logger.debug("\(controller.playbackState.rawValue)")
            playButton.setImage(UIImage(named: "ic_play_circle_outline_48px"), forState: .Normal)
            break
        }
    }
}
