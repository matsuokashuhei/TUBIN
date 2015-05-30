//
//  YouTubePlayer.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import MediaPlayer
import AVFoundation
import YouTubeKit
import XCGLogger
import Result
import Box
import Async

protocol YouTubePlayerDelegate {
    // 再生の準備したとき
    func prepareToPlay(video: Video)
    // 再生の準備に失敗したとき
    func playbackFailed(error: NSError)
    // 再生時間がわかったとき
    func durationAvailable(controller: MPMoviePlayerController)
    // 再生の準備ができたとき
    func readyForDisplay(controller: MPMoviePlayerController)
    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController)
    func playingAtTime(controller: MPMoviePlayerController)
    func playbackDidFinish(controller: MPMoviePlayerController)
    func playBackStateDidChange(controller: MPMoviePlayerController)
}

class YouTubePlayer: NSObject {

    let logger = XCGLogger.defaultInstance()

    let controller: MPMoviePlayerController

    var delegate: YouTubePlayerDelegate?

    var playlist: [Video]!
    var nowPlaying: Video! {
        didSet(didPlaying) {
            if let didPlaying = didPlaying {
                if didPlaying.id == nowPlaying.id {
                    if controller.playbackState == .Playing {
                        return
                    } else {
                        play()
                    }
                } else {
                    stop()
                    startPlaying()
                }
            } else {
                stop()
                startPlaying()
            }
        }
    }

    var playInBackground = false {
        didSet {
            logger.debug("playInBackground: \(self.playInBackground)")
        }
    }

    static let sharedInstance = YouTubePlayer()

    override init() {
        logger.debug("")
        controller = MPMoviePlayerController()
        controller.controlStyle = .None
        controller.shouldAutoplay = false
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playBackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: controller)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        // バックグランドでの再生とマナーモードでの音声出力の設定
        var error: NSError?
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: &error)
        if let error = error {
            logger.error(error.localizedDescription)
        }
//        AVAudioSession.sharedInstance().setActive(true, error: &error)
//        if let error = error {
//            logger.error(error.localizedDescription)
//        }

    }

    func startPlaying() {
        logger.debug("")
        let video = nowPlaying
        delegate?.prepareToPlay(video)
        video.streamURL { (result) -> Void in
            switch result {
            case .Success(let box):
                self.startPlaying(box.value)
                video.playingInfo { result in
                    switch result {
                    case .Success(let box):
                        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = result.value
                    default:
                        break
                    }
                }
            case .Failure(let box):
                self.controller.contentURL = nil
                let error = box.value
                self.logger.error(error.localizedDescription)
                self.delegate?.playbackFailed(error)
            }
        }
    }

    func startPlaying(URL: NSURL) {
        logger.debug("")
        playInBackground = true
        addObservers()
        controller.contentURL = URL
        controller.prepareToPlay()
    }

    func play() {
        playInBackground = true
        logger.debug("")
        if let contentURL = controller.contentURL {
            controller.play()
        } else {
            startPlaying()
        }
    }

    func pause() {
        logger.debug("")
        playInBackground = false
        controller.pause()
    }

    func stop() {
        logger.debug("")
        playInBackground = false
        removeObservers()
        controller.stop()
    }

    func nextVideo() -> Video? {
        logger.debug("")
        playInBackground = true
        let index = (playlist as NSArray).indexOfObject(nowPlaying) + 1
        if index < playlist.count {
            return playlist[index]
        }
        return nil
    }

    func previousVideo() -> Video? {
        logger.debug("")
        playInBackground = true
        let index = (playlist as NSArray).indexOfObject(nowPlaying) - 1
        if index >= 0  {
            return playlist[index]
        }
        return nil
    }

    func playNextVideo() {
        logger.debug("")
        if let video = nextVideo() {
            nowPlaying = video
        }
    }

    func playPreviousVideo() {
        logger.debug("")
        if controller.currentPlaybackTime > 5 {
            startPlaying()
            return
        }
        if let video = previousVideo() {
            nowPlaying = video
        }
    }

}

extension YouTubePlayer {

    // MARK: Notifications
    func addObservers() {
        removeObservers()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "durationAvailable:", name: MPMovieDurationAvailableNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "readyForDisplay:", name: MPMoviePlayerReadyForDisplayDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaIsPreparedToPlayDidChange:", name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: controller)
    }

    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMovieDurationAvailableNotification, object: controller)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerReadyForDisplayDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: controller)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: controller)
    }

    func durationAvailable(notification: NSNotification) {
        //if let player = notification.object as? MPMoviePlayerController {
            if isnormal(controller.duration) {
                delegate?.durationAvailable(controller)
            }
        //}
    }

    func readyForDisplay(notification: NSNotification) {
        logger.debug("")
        //if let controller = notification.object as? MPMoviePlayerController {
            delegate?.readyForDisplay(controller)
        //}
    }

    func loadStateDidChange(notification: NSNotification) {
        //if let controller = notification.object as? MPMoviePlayerController {
            switch controller.loadState {
            case MPMovieLoadState.Unknown:
                logger.verbose("Unknown")
            case MPMovieLoadState.Playable:
                logger.verbose("Playable")
            case MPMovieLoadState.PlaythroughOK:
                logger.verbose("PlaythroughOK")
            case MPMovieLoadState.Stalled:
                logger.verbose("Stalled")
            default:
                logger.verbose("\(self.controller.loadState)")
            }
        //}
    }

    func playbackDidFinish(notification: NSNotification) {
        logger.debug("")
        playNextVideo()
        //if let controller = notification.object as? MPMoviePlayerController {
            delegate?.playbackDidFinish(controller)
        //}
    }

    func mediaIsPreparedToPlayDidChange(notification: NSNotification) {
        logger.debug("")
        switch UIApplication.sharedApplication().applicationState {
        case .Active:
            delegate?.mediaIsPreparedToPlayDidChange(controller)
            Timer.start(target: self, selector: "playingAtTime")
        case .Background:
            if playInBackground {
                delegate?.mediaIsPreparedToPlayDidChange(controller)
                Timer.start(target: self, selector: "playingAtTime")
            }
        case .Inactive:
            break
        }
//        if let controller = notification.object as? MPMoviePlayerController {
//            delegate?.mediaIsPreparedToPlayDidChange(controller)
//            Timer.start(target: self, selector: "playingAtTime")
//        }
    }

    func playBackStateDidChange(notification: NSNotification) {
        //if let controller = notification.object as? MPMoviePlayerController {
            switch controller.playbackState {
            case .Stopped:
                logger.debug("Stopped")
            case .Playing:
                logger.debug("Playing")
            case .Paused:
                logger.debug("Paused")
            case .Interrupted:
                logger.debug("Interrupted")
            case .SeekingForward:
                logger.debug("SeekingForward")
            case .SeekingBackward:
                logger.debug("SeekingBackward")
            }
            delegate?.playBackStateDidChange(controller)
        //}
    }

    // MARK: - Timer

    func playingAtTime() {
        delegate?.playingAtTime(controller)
    }

    func seekToTime(seconds: Float) {
        controller.currentPlaybackTime = Double(seconds)
    }

    class Timer {

        class func start(#target: AnyObject, selector: Selector) {
            sharedInstance.start(target: target, selector: selector)
        }

        class func stop() {
            sharedInstance.stop()
        }

        var timer: NSTimer? {
            willSet {
                stop()
            }
        }

        static var sharedInstance = Timer()

        func start(#target: AnyObject, selector: Selector) {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: target, selector: selector, userInfo: nil, repeats: true)
        }

        func stop() {
            if let timer = timer {
                timer.invalidate()
            }
        }

    }

}

extension YouTubePlayer {

    func applicationDidEnterBackground(notification: NSNotification) {
        logger.debug("playInBackground: \(self.playInBackground)")
        if playInBackground {
            self.logger.debug("")
            Async.main(after: 2.0) {
                self.logger.debug("")
                //if self.controller.playbackState != .Playing {
                    //self.logger.debug("play()")
                    //self.play()
                //}
                self.delegate?.mediaIsPreparedToPlayDidChange(self.controller)
            }
        }
    }
}