//
//  MiniPlayerView.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import UIKit
import MediaPlayer

protocol MiniPlayerViewDelegate {
    func backToVideoPlayerViewController()
}

class MiniPlayerView: UIView {

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
        // TODO: 再生の準備〜再生の間の場合は、ミニプレーヤーが出ない。
        if player.isPlaying() {
            playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
            height.constant = 86
            hidden = false
            addPlayerView(player.controller)
        }
    }

    func hide() {
        height.constant = 0
        hidden = true
    }

    func playButtonTapped(button: UIButton) {
        if player.isPlaying() {
            player.pause()
            playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Normal)
        } else {
            player.play()
            playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
        }
    }

    func previousButtonTapped(button: UIButton) {
        // TODO:
    }

    func nextButtonTapped(button: UIButton) {
        // TODO:
    }

    func backToVideoPlayerViewController() {
        hide()
        delegate?.backToVideoPlayerViewController()
    }

    func addPlayerView(controller: MPMoviePlayerController) {
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
}

/*
import UIKit
import AVFoundation
import YouTubeKit

protocol MiniPlayerViewDelegate {
    func backToVideoPlayerViewController(video: Video)
}

class MiniPlayerView: UIView {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var playerView: AVPlayerView!

    @IBOutlet var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: "play", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet var backwardButton: UIButton! {
        didSet {
            backwardButton.addTarget(self, action: "backward", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet var forwardButton: UIButton! {
        didSet {
            forwardButton.addTarget(self, action: "forward", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: "backToVideoPlayerViewController", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet weak var height: NSLayoutConstraint!

    var videoPlayer: VideoPlayer = VideoPlayer.sharedInstance {
        didSet {
            videoPlayer.delegate = self
        }
    }

    var delegate: MiniPlayerViewDelegate?

    func show() {
        if videoPlayer.isPlayling() {
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
            height.constant = 78
            hidden = false
            showMovie(true)
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
        }
    }

    func hide() {
        height.constant = 0
        hidden = true
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
    }

    func showMovie(showable: Bool) {
        if showable {
            let playerLayer = playerView.layer as AVPlayerLayer
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            playerLayer.player = videoPlayer.player
        }
    }

    func play() {
        if videoPlayer.isPlayling() {
            videoPlayer.pause()
            playButton.setImage(UIImage(named: "play"), forState: .Normal)
        } else {
            videoPlayer.play()
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        }
    }

    func backward() {
        if videoPlayer.playlist.canBackward() {
            videoPlayer.playlist.backward()
            videoPlayer.prepareToPlay()
        }
    }

    func forward() {
        if videoPlayer.playlist.canForward() {
            videoPlayer.playlist.forward()
            videoPlayer.prepareToPlay()
        }
    }

    func backToVideoPlayerViewController() {
        let video = videoPlayer.playlist.playingVideo()
        delegate?.backToVideoPlayerViewController(video)
    }

}

extension MiniPlayerView: VideoPlayerDelegate {

    func didStartBuffering(player: AVPlayer) {
    }

    func didStartPlaying(item: AVPlayerItem) {
    }

    func playingAtTime(time: CMTime, duration: CMTime) {
    }

    func didFinishPlaying() {
    }

}
*/