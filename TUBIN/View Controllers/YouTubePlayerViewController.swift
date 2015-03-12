//
//  YouTubePlayerViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import MediaPlayer
import YouTubeKit

class YouTubePlayerViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var videoView: UIView!
    @IBOutlet var scrubberView: ScrubberView! {
        didSet {
            scrubberView.delegate = self
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

    var player = YouTubePlayer.sharedInstance

    var video: Video!
    var playlist: [Video]!

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.None

        player.nowPlaying = video
        player.playlist = playlist
    }

    override func viewWillAppear(animated: Bool) {
        player.delegate = nil
        navigationController?.setNavigationBarHidden(false, animated: true)
        configure(navigationItem: navigationItem)
        scrubberView.sync(player.controller)
        addPlayerView(player.controller)
        if player.isPlaying() {
            playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
        } else {
            playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Disabled)
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        // Notification to Mini player
        NSNotificationCenter.defaultCenter().postNotificationName(ShowMiniPlayerNotification, object: self)
        player.delegate = nil
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = video.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        Favorite.exists(video) { (result) in
            switch result {
            case .Success(let box):
                if box.unbox {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                } else {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                }
            case .Failure(let box):
                let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                self.navigationItem.rightBarButtonItem = favoriteButton
            }
        }
    }

    // MARK: - Actions
    func playButtonTapped(button: UIButton) {
        if player.isPlaying() {
            pause()
        } else {
            play()
        }
    }

    func previousButtonTapped(button: UIButton) {
        // TODO:
    }

    func nextButtonTapped(button: UIButton) {
        // TODO:
    }

    func play() {
        player.play()
        //playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
    }

    func pause() {
        player.pause()
        //playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Normal)
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Actions
    func addVideoToFavorite() {

        //navigationItem.rightBarButtonItem?.enabled = true
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        indicator.color = view.tintColor
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)

        Favorite.add(video) { (result) in
            indicator.stopAnimating()
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToFavoritesNotification, object: self, userInfo: ["item": self.video]))
                Async.main {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                }
            case .Failure(let box):
                let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                self.navigationItem.rightBarButtonItem = favoriteButton
                Alert.error(box.unbox)
            }
        }
    }

    func removeFromFavorite() {
        navigationItem.rightBarButtonItem?.enabled = true
        Favorite.remove(video) { (result) in
            self.navigationItem.rightBarButtonItem?.enabled = false
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ReloadFavoritesNotification, object: self))
                Async.main {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                }
            case .Failure(let box):
                Alert.error(box.unbox)
            }
        }
    }
}

extension YouTubePlayerViewController: YouTubePlayerDelegate {

    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController) {
        logger.debug("")
//        addPlayerView(controller)
//        scrubberView.configure(controller.duration)
    }

    func playingAtTime(controller: MPMoviePlayerController) {
        scrubberView.setTime(controller.currentPlaybackTime, duration: controller.duration)
    }

    func playbackDidFinish(controller: MPMoviePlayerController) {
        logger.debug("")
    }

    func playBackStateDidChange(controller: MPMoviePlayerController) {
        switch controller.playbackState {
        case .Playing:
            playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
        case .Paused, .Stopped:
            playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Normal)
        default:
            break
        }
    }
}

extension YouTubePlayerViewController: ScrubberViewDelegate {

    func beginSeek(slider: UISlider) {
        logger.debug("")
        player.pause()
    }

    func seekPositionChanged(slider: UISlider) {
        logger.debug("")
        seekToSeconds(slider.value)
    }

    func endSeek(slider: UISlider) {
        logger.debug("")
        player.play()
    }

    func seekToSeconds(seconds: Float) {
        logger.debug("")
        player.seekToTime(seconds)
    }
}