//
//  VideoPlayer.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/02.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import AVFoundation
import MediaPlayer
import UIKit

import SVProgressHUD
import YouTubeKit

protocol VideoPlayerDelegate {
    func didStartBuffering(player: AVPlayer)
    func didStartPlaying(item: AVPlayerItem)
    func playingAtTime(time: CMTime, duration: CMTime)
    func didFinishPlaying()
    /*
    func videoPlayerDidStartPlaying()
    func videoPlayerDidStartBuffering()
    func videoPlayerDidPause()
    func videoPlayerDidFinishPlaying()
    */
}

class VideoPlayer: NSObject {

    let logger = XCGLogger.defaultInstance()

    let controller: VideoPlayerViewController

    let RateObservationContext = UnsafeMutablePointer<Int>(bitPattern: 1)
    let StatusObservationContext = UnsafeMutablePointer<Int>(bitPattern: 2)
    let ItemObservationContext = UnsafeMutablePointer<Int>(bitPattern: 3)

    struct Playlist {
        var videos: [Video]
        var index: Int
        init(videos: [Video], index: Int = 0) {
            self.videos = videos
            self.index = index
        }
        func playingVideo() -> Video {
            return videos[index]
        }
        func canBackward() -> Bool {
            return valid(index: index - 1)
        }
        mutating func backward() {
            if canBackward() {
                index -= 1
            }
        }
        func canForward() -> Bool {
            return valid(index: index + 1)
        }
        mutating func forward() {
            if canForward() {
                index += 1
            }
        }
        func valid(#index: Int) -> Bool {
            switch index {
            case 0 ..< videos.count:
                return true
            default:
                return false
            }
        }
    }
    var playlist: Playlist!

    var player: AVPlayer! {
        didSet {
            logger.debug("player.addObserver(self, forKeyPath: \"currentItem\", options: (.Initial | .New), context: ItemObservationContext)")
            player.addObserver(self, forKeyPath: "currentItem", options: (.Initial | .New), context: ItemObservationContext)
            logger.debug("player.addObserver(self, forKeyPath: \"rate\", options: (.Initial | .New), context: RateObservationContext)")
            player.addObserver(self, forKeyPath: "rate", options: (.Initial | .New), context: RateObservationContext)
        }
    }

    var item: AVPlayerItem! {
        willSet {
            if let item = item {
                item.removeObserver(self, forKeyPath: "status")
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            }
        }
        didSet {
            item.addObserver(self, forKeyPath: "status", options: (.Initial | .New), context: StatusObservationContext)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        }
    }

    var periodicTimeObserver: AnyObject? {
        willSet {
            if periodicTimeObserver != nil {
                player?.removeTimeObserver(periodicTimeObserver)
            }
        }
    }

    var delegate: VideoPlayerDelegate?

    class var sharedInstance: VideoPlayer {
        struct Singleton {
            static let instance = VideoPlayer()
        }
        return Singleton.instance
    }

    override init() {
        // バックグラウンド再生
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        // ミニプレーヤー用のVideoViewControllerの作成
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        controller = storyboard.instantiateViewControllerWithIdentifier("VideoPlayerViewController") as VideoPlayerViewController
    }

    func setPlaylist(#videos: [Video], index: Int) {
        playlist = Playlist(videos: videos, index: index)
    }

    func prepareToPlay() {
        // 通知
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: VideoPlayerDidPrepareToPlayNotification, object: self))
        // ビデオのURLの取得
        let video = playlist.playingVideo()
        if let fileURL = video.fileURL() {
            logger.debug("fileURL: \(fileURL)")
            prepareToPlay(fileURL)
            return
        }
        video.streamURL { (result) -> Void in
            switch result {
            case .Success(let box):
                self.prepareToPlay(box.unbox)
            case .Failure(let box):
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
        /*
        if let fileURL = video.fileURL {
            logger.debug("fileURL: \(fileURL)")
            prepareToPlay(fileURL)
        } else {
            video.streamURL(completion: { (streamURL, error) -> Void in
                if let streamURL = streamURL {
                    // AVPlayerの準備
                    self.prepareToPlay(streamURL)
                } else {
                    // TODO: エラー処理
                }
            })
        }
        */
    }

    func prepareToPlay(URL: NSURL) {
        /*
        MEMO
        再生中の動画を保存する方法
        https://gist.github.com/anonymous/83a93746d1ea52e9d23f
        */
        var item = AVPlayerItem(URL: URL)
        if let player = player {
            if (item.asset as AVURLAsset).URL != (self.item.asset as AVURLAsset).URL {
                self.item = item
                player.replaceCurrentItemWithPlayerItem(item)
            }
        } else {
            self.item = item
            player = AVPlayer(playerItem: item)
        }
        delegate?.didStartBuffering(player)
    }

    func startTimer() {
        let item = player.currentItem
        let second = CMTimeMakeWithSeconds(1, Int32(NSEC_PER_SEC))
        periodicTimeObserver = player.addPeriodicTimeObserverForInterval(second, queue: dispatch_get_main_queue()) { (time: CMTime) in
            self.playingAtTime(time, duration: item.duration)
        }
    }

    func playingAtTime(time: CMTime, duration: CMTime) {
        delegate?.playingAtTime(time, duration: duration)

    }

    func startPlaying() {
        delegate?.didStartPlaying(player.currentItem)
        startTimer()
        setNowPlayingInfo(playlist.playingVideo())
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func removeTimeObserver() {
        player?.removeTimeObserver(periodicTimeObserver)
    }

    func playerItemDuration() -> CMTime {
        if let item = player?.currentItem {
            if item.status == .ReadyToPlay {
                item.duration
            }
        }
        return kCMTimeInvalid
    }

    func seekToTime(time: CMTime) {
        if let player = player {
            player.seekToTime(time)
        }
    }

    func isPlayling() -> Bool {
        if let player = player {
            return player.rate != 0
        }
        return false
    }
}

extension VideoPlayer {

    // MARK: - Notifications

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch context {
        case StatusObservationContext:
            if let status = change[NSKeyValueChangeNewKey] as? Int {
                if let status = AVPlayerItemStatus(rawValue: status) {
                    switch status {
                    case .Unknown:
                        self.logger.debug("Unknown")
                        // コントローラーを操作不能にする。
                        // スクラバーを0にしてきかなくする。
                        // 再生ボタンや停止ボタンをきかなくする。
                        break
                    case .ReadyToPlay:
                        self.logger.debug("ReadyToPlay")
                        startPlaying()
                        break
                    case .Failed:
                        self.logger.debug("Failed")
                        break
                    default:
                        break
                    }
                } else {
                    logger.debug("AVPlayerItemStatus(rawValue: status) がnil")
                }
            }
        case RateObservationContext:
            logger.debug("context: RateObservationContext, rate: \(player.rate)")
            break
        case ItemObservationContext:
            logger.debug("context: ItemObservationContext")
        default:
            logger.debug("default")
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    func playerItemDidReachEnd(notification: NSNotification) {
        delegate?.didFinishPlaying()
        if playlist.canForward() {
            playlist.forward()
            prepareToPlay()
        }
    }

}

extension VideoPlayer {

    // Background
    func remoteControlReceivedWithEvent(event: UIEvent) {
        logger.debug("event.typ: \(event.type)")
        switch event.type {
        case .RemoteControl:
            switch event.subtype {
            case .RemoteControlTogglePlayPause:
                logger.debug(".RemoteControlTogglePlayPause")
                if isPlayling() {
                    pause()
                } else {
                    play()
                }
            case .RemoteControlPlay:
                play()
            case .RemoteControlPause:
                pause()
            case .RemoteControlPreviousTrack:
                if playlist.canBackward() {
                    playlist.backward()
                    prepareToPlay()
                }
            case .RemoteControlNextTrack:
                if playlist.canForward() {
                    playlist.forward()
                    prepareToPlay()
                }
            default:
                break
            }
        default:
            break
        }
    }

    func setNowPlayingInfo(video: Video) {
        var info = [String: AnyObject]()
        info[MPMediaItemPropertyTitle] = video.title
        video.thumbnailImage { (result) -> Void in
            switch result {
            case .Success(let box):
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: box.unbox)
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
                break
            }
        }
    }
}

extension CMTime {

    var isValid: Bool {
        return (flags & .Valid) != nil
    }

}