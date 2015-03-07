//
//  MiniPlayerView.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

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