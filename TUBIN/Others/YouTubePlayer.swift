//
//  YouTubePlayer.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import MediaPlayer
import YouTubeKit

protocol YouTubePlayerDelegate {
    func prepareToPlay(video: Video)
    func durationAvailable(controller: MPMoviePlayerController)
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
            logger.debug(debug(controller))
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

    class var sharedInstance: YouTubePlayer {
        struct Singleton {
            static let instance = YouTubePlayer()
        }
        return Singleton.instance
    }

    override init() {
        controller = MPMoviePlayerController()
        controller.controlStyle = .None
        controller.shouldAutoplay = false
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playBackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: controller)
    }

    func startPlaying() {
        let video = nowPlaying
        delegate?.prepareToPlay(video)
        if let fileURL = video.fileURL() {
            startPlaying(fileURL)
        } else {
            video.streamURL { (result) -> Void in
                switch result {
                case .Success(let box):
                    self.startPlaying(box.unbox)
                case .Failure(let box):
                    self.controller.contentURL = nil
                    self.logger.error(box.unbox.localizedDescription)
                    Alert.error(box.unbox)
                }
            }
        }
    }

    func startPlaying(URL: NSURL) {
        addObservers()
        controller.contentURL = URL
        controller.prepareToPlay()
    }

    func play() {
        if let contentURL = controller.contentURL {
            controller.play()
        } else {
            startPlaying()
        }
    }

    func pause() {
        controller.pause()
    }

    func stop() {
        removeObservers()
        controller.stop()
    }

    func nextVideo() -> Video? {
        let index = (playlist as NSArray).indexOfObject(nowPlaying) + 1
        if index < playlist.count {
            return playlist[index]
        }
        return nil
    }

    func previousVideo() -> Video? {
        let index = (playlist as NSArray).indexOfObject(nowPlaying) - 1
        if index >= 0  {
            return playlist[index]
        }
        return nil
    }

    func playNextVideo() {
        if let video = nextVideo() {
            nowPlaying = video
        }
    }

    func playPreviousVideo() {
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
        logger.debug("")
        removeObservers()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "durationAvailable:", name: MPMovieDurationAvailableNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "readyForDisplay:", name: MPMoviePlayerReadyForDisplayDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaIsPreparedToPlayDidChange:", name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: controller)
    }

    func removeObservers() {
        logger.debug("")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMovieDurationAvailableNotification, object: controller)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerReadyForDisplayDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: controller)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: controller)
    }

    func durationAvailable(notification: NSNotification) {
        logger.debug("")
        if let player = notification.object as? MPMoviePlayerController {
            if isnormal(player.duration) {
                delegate?.durationAvailable(controller)
            }
        }
    }

    func readyForDisplay(notification: NSNotification) {
        logger.debug("")
        if let controller = notification.object as? MPMoviePlayerController {
            delegate?.readyForDisplay(controller)
        }
    }

    func loadStateDidChange(notification: NSNotification) {
        if let controller = notification.object as? MPMoviePlayerController {
            switch controller.loadState {
            case MPMovieLoadState.Unknown:
                logger.debug("Unknown")
            case MPMovieLoadState.Playable:
                logger.debug("Playable")
            case MPMovieLoadState.PlaythroughOK:
                logger.debug("PlaythroughOK")
            case MPMovieLoadState.Stalled:
                logger.debug("Stalled")
            default:
                logger.debug("\(controller.loadState)")
            }
        }
    }

    func playbackDidFinish(notification: NSNotification) {
        logger.debug("")
        playNextVideo()
        if let controller = notification.object as? MPMoviePlayerController {
            delegate?.playbackDidFinish(controller)
        }
    }

    func mediaIsPreparedToPlayDidChange(notification: NSNotification) {
        logger.debug("")
        if let controller = notification.object as? MPMoviePlayerController {
            delegate?.mediaIsPreparedToPlayDidChange(controller)
            Timer.start(target: self, selector: "playingAtTime")
        }
    }

    func playBackStateDidChange(notification: NSNotification) {
        if let controller = notification.object as? MPMoviePlayerController {
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
        }
    }

    // MARK: - Timer

    func playingAtTime() {
        delegate?.playingAtTime(controller)
    }

    func seekToTime(seconds: Float) {
        controller.currentPlaybackTime = Double(seconds)
    }

    // MARK: - Debug
    func debug(controller: MPMoviePlayerController) -> String {
        var message = "controller: "
        message += "playbackState: "
        switch controller.playbackState {
        case .Stopped:
            message += "Stopped"
        case .Playing:
            message += "Playing"
        case .Paused:
            message += "Paused"
        case .Interrupted:
            message += "Interrupted"
        case .SeekingForward:
            message += "SeekingForward"
        case .SeekingBackward:
            message += "SeekingBackward"
        }
        message += ", loadState: "
        switch controller.loadState {
        case MPMovieLoadState.Unknown:
            message += "Unknown"
        case MPMovieLoadState.Playable:
            message += "Playable"
        case MPMovieLoadState.PlaythroughOK:
            message += "PlaythroughOK"
        case MPMovieLoadState.Stalled:
            message += "Stalled"
        default:
            message += "?"
        }
        return message
    }
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

    class var sharedInstance: Timer {
        struct Singleton {
            static let instance = Timer()
        }
        return Singleton.instance
    }

    func start(#target: AnyObject, selector: Selector) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: target, selector: selector, userInfo: nil, repeats: true)
    }

    func stop() {
        if let timer = timer {
            timer.invalidate()
        }
    }

}