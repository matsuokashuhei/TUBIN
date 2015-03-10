//
//  YouTubePlayer.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import MediaPlayer
import YouTubeKit
import SVProgressHUD

protocol YouTubePlayerDelegate {
    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController)
    func playingAtTime(controller: MPMoviePlayerController)
    func moviePlaybackDidFinish(controller: MPMoviePlayerController)
}

class YouTubePlayer: NSObject {

    let logger = XCGLogger.defaultInstance()

    let controller: MPMoviePlayerController

    var delegate: YouTubePlayerDelegate?

    let observers = [
        MPMoviePlayerLoadStateDidChangeNotification, "loadStateDidChange",
        MPMoviePlayerPlaybackDidFinishNotification, "moviePlaybackDidFinish",
        MPMediaPlaybackIsPreparedToPlayDidChangeNotification, "mediaIsPreparedToPlayDidChange",
        MPMoviePlayerPlaybackStateDidChangeNotification, "moviePlayBackStateDidChange"
    ]

    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaIsPreparedToPlayDidChange:", name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: controller)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayBackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: controller)
    }

    func removeObservers() {
       NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerLoadStateDidChangeNotification, object: controller)
       NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: controller)
       NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: controller)
       NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackStateDidChangeNotification, object: controller)
    }

    var playlist: [Video]!
    var nowPlaying: Video! {
        /*
        willSet(willPlaying) {
            if let nowPlaying = nowPlaying {
                println(nowPlaying.id)
                println(willPlaying.id)
                if nowPlaying.id != willPlaying.id {
                    removeObservers()
                }
            }
        }
        */
        didSet(didPlaying) {
            if let didPlaying = didPlaying {
                if nowPlaying.id == didPlaying.id {
                    return
                }
            }
            removeObservers()
            addObservers()
            startPlaying()
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
        controller.shouldAutoplay = true
        controller.scalingMode = MPMovieScalingMode.AspectFit
        //player.movieSourceType = MPMovieSourceType.Streaming
        super.init()
    }

    /*
    func setPlaylist(videos: [Video], index: Int) {
        playlist = Playlist(videos: videos, index: index)
    }
    */

    func startPlaying() {
        startPlaying(nowPlaying)
    }

    func startPlaying(video: Video) {
        video.streamURL { (result) -> Void in
            switch result {
            case .Success(let box):
                self.startPlaying(box.unbox)
            case .Failure(let box):
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
    }

    func startPlaying(streamURL: NSURL) {
        controller.contentURL = streamURL
        controller.prepareToPlay()
    }

    func play() {
        controller.play()
    }

    func pause() {
        controller.pause()
    }

    func loadStateDidChange(notification: NSNotification) {
        if let player = notification.object as? MPMoviePlayerController {
            switch player.loadState {
            case MPMovieLoadState.Unknown:
                logger.debug("Unknown")
            case MPMovieLoadState.Playable:
                logger.debug("Playable")
            case MPMovieLoadState.PlaythroughOK:
                logger.debug("PlaythroughOK")
                logger.debug("player.duration: \(player.duration)")
            case MPMovieLoadState.Stalled:
                logger.debug("Stalled")
            default:
                logger.debug("\(player.loadState)")
            }
        }
    }

    func moviePlaybackDidFinish(notification: NSNotification) {
        logger.debug("")
        //stopTimer()
    }

    func mediaIsPreparedToPlayDidChange(notification: NSNotification) {
        logger.debug("")
        if let player = notification.object as? MPMoviePlayerController {
            logger.debug("player.duration: \(player.duration)")
            delegate?.mediaIsPreparedToPlayDidChange(player)
            Timer.start(target: self, selector: "playingAtTime")
        }
    }

    func moviePlayBackStateDidChange(notification: NSNotification) {
        if let player = notification.object as? MPMoviePlayerController {
            switch player.playbackState {
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
        }
    }

    func isPlaying() -> Bool {
        switch controller.playbackState {
        case .Playing:
            return true
        default:
            return false
        }
    }

    func playingAtTime() {
        delegate?.playingAtTime(controller)
    }

    func seekToTime(seconds: Float) {
        controller.currentPlaybackTime = Double(seconds)
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