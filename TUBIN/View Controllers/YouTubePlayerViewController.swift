//
//  YouTubePlayerViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/08.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import MediaPlayer
import SVProgressHUD

class YouTubePlayerViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var videoView: UIView!
    @IBOutlet var scrubberView: ScrubberView! {
        didSet {
            scrubberView.delegate = self
        }
    }
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: "tapPlayButton:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet var nextButton: UIButton!

    var player = YouTubePlayer.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.None

        player.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
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
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configure(#navigationItem: UINavigationItem) {
        let video = player.nowPlaying
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
    func tapPlayButton(button: UIButton) {
        if player.isPlaying() {
            pause()
        } else {
            play()
        }
    }

    func play() {
        player.play()
        playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
    }

    func pause() {
        player.pause()
        playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Normal)
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
        let video = player.nowPlaying
        Favorite.add(video) { (result) in
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToFavoritesNotification, object: self, userInfo: ["item": video]))
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
    }

    func removeFromFavorite() {
        let video = player.nowPlaying
        Favorite.remove(video) { (result) in
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: ReloadFavoritesNotification, object: self))
                Async.main {
                    let favoriteButton = UIBarButtonItem(image: UIImage(named: "ic_favorite_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addVideoToFavorite")
                    self.navigationItem.rightBarButtonItem = favoriteButton
                }
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
    }
}

extension YouTubePlayerViewController: YouTubePlayerDelegate {

    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController) {
        logger.debug("")
        playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
        addPlayerView(controller)
        scrubberView.configure(controller.duration)
    }

    func playingAtTime(controller: MPMoviePlayerController) {
        scrubberView.setTime(controller.currentPlaybackTime, duration: controller.duration)
    }

    func moviePlaybackDidFinish(controller: MPMoviePlayerController) {
        logger.debug("")
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