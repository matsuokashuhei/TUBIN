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
    func mediaIsPreparedToPlayDidChange(player: MPMoviePlayerController)
}

class YouTubePlayer: NSObject {

    let logger = XCGLogger.defaultInstance()

    let player: MPMoviePlayerController

    var delegate: YouTubePlayerDelegate?

    var video: Video! {
        willSet {
            if let video = video {
               NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerLoadStateDidChangeNotification, object: player)
               NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
               NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: player)
               NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackStateDidChangeNotification, object: player)
            }
        }
        didSet {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: player)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaIsPreparedToPlayDidChange:", name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: player)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayBackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: player)
        }
    }

    struct Playlist {
        let videos: [Video]
        var index: Int
        func currentVideo() -> Video {
            return videos[index]
        }
    }
    var playlist: Playlist!

    class var sharedInstance: YouTubePlayer {
        struct Singleton {
            static let instance = YouTubePlayer()
        }
        return Singleton.instance
    }

    override init() {
        player = MPMoviePlayerController()
        player.controlStyle = .None
        //player.movieSourceType = MPMovieSourceType.Streaming
        super.init()
    }

    func setPlaylist(videos: [Video], index: Int) {
        playlist = Playlist(videos: videos, index: index)
    }

    func startPlaying() {
        let video = playlist.currentVideo()
        startPlaying(video)
    }

    func startPlaying(video: Video) {
        self.video = video
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
        player.contentURL = streamURL
        player.prepareToPlay()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
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
    }

    func mediaIsPreparedToPlayDidChange(notification: NSNotification) {
        logger.debug("")
        if let player = notification.object as? MPMoviePlayerController {
            logger.debug("player.duration: \(player.duration)")
            delegate?.mediaIsPreparedToPlayDidChange(player)
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
        switch player.playbackState {
        case .Playing:
            return true
        default:
            return false
        }
    }
}