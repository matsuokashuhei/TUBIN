//
//  MoviePlayerView.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/04.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayerViewDelegate {
    // 次のビデオを再生する。
    func playNextVideo()
    // 前のビデオを再生する。
    func playPrevVideo()
    // コントローラーを見せる／隠す
    func showOnlyVideo(showable: Bool)
}

class VideoPlayerView: UIView {

    let logger = XCGLogger.defaultInstance()

    var videoPlayer: VideoPlayer!

    var delegate: VideoPlayerViewDelegate?

    @IBOutlet weak var playerView: AVPlayerView! {
        didSet {
            playerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedMovieView"))
        }
    }
    @IBOutlet weak var scrubberView: ScrubberView! {
        didSet {
            scrubberView.delegate = self
        }
    }
    @IBOutlet weak var prevButton: UIButton! {
        didSet {
            prevButton.addTarget(self, action: "backward", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: "onClickPlayButton", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.addTarget(self, action: "forward", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var channelView: UIView!

    override func willMoveToSuperview(newSuperview: UIView?) {
        videoPlayer = VideoPlayer.sharedInstance
        videoPlayer.delegate = self
    }

    // MARK: - Configurations

    // MARK: - Actions

    func tappedMovieView() {
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            switch UIDevice.currentDevice().orientation {
            case .LandscapeLeft, .LandscapeRight:
                showOnlyVideo = !showOnlyVideo
            default:
                break
            }
        default:
            break
        }
    }

    // MARK: - Player control

    var playable: Bool = false {
        didSet {
            playButton.enabled = playable
        }
    }

    var showOnlyVideo: Bool = false {
        didSet {
            scrubberView.hidden = showOnlyVideo
            playButton.hidden = showOnlyVideo
            prevButton.hidden = showOnlyVideo
            nextButton.hidden = showOnlyVideo
            delegate?.showOnlyVideo(showOnlyVideo)
        }
    }

    func startPlaying() {
        videoPlayer.prepareToPlay()
    }

    func show() {
        let playerLayer = playerView.layer as AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.player = videoPlayer.player
    }

    /**
    再生の準備
    */

    func onClickPlayButton() {
        if videoPlayer.isPlayling() {
            pause()
        } else {
            play()
        }
    }

    /**
    再生
    */
    
    func play() {
        let playerLayer = playerView.layer as AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.player = videoPlayer.player
        playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        videoPlayer.play()
    }

    /**
    一時停止
    */
    func pause() {
        videoPlayer.pause()
        playButton.setImage(UIImage(named: "play"), forState: .Normal)
    }

    func stop() {
        pause()
        scrubberView.configure()
    }

    /**
    次
    */
    func forward() {
        stop()
        if videoPlayer.playlist.canForward() {
            videoPlayer.playlist.forward()
            videoPlayer.prepareToPlay()
        }
    }

    /**
    前
    */
    func backward() {
        stop()
        if videoPlayer.playlist.canBackward() {
            videoPlayer.playlist.backward()
            videoPlayer.prepareToPlay()
        }
    }

}

extension VideoPlayerView: VideoPlayerDelegate {

    func didStartBuffering(player: AVPlayer) {
        logger.debug("")
        let playerLayer = playerView.layer as AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.player = player
    }

    func didStartPlaying(item: AVPlayerItem) {
        logger.debug("")
        playable = true
        scrubberView.configure(item.duration)
        play()
    }

    func playingAtTime(time: CMTime, duration: CMTime) {
        logger.verbose("time: \(time), duration: \(duration)")
        scrubberView.setTime(time, duration: duration)
    }

    func didFinishPlaying() {
    }

}

extension VideoPlayerView: ScrubberViewDelegate {

    func beginSeek(slider: UISlider) {
        logger.debug("")
        videoPlayer.pause()
    }

    func seekPositionChanged(slider: UISlider) {
        logger.debug("")
        seekToSeconds(slider.value)
    }

    func endSeek(slider: UISlider) {
        logger.debug("")
        videoPlayer.play()
    }

    func seekToSeconds(seconds: Float) {
        logger.debug("")
        let time = CMTimeMakeWithSeconds(Float64(seconds), Int32(NSEC_PER_SEC))
        videoPlayer.seekToTime(time)
    }

}

class AVPlayerView: UIView {

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

}
