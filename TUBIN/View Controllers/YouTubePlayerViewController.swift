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
import SVProgressHUD

class YouTubePlayerViewController: UIViewController {

    @IBOutlet var videoView: UIView!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: "tapPlayButton:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet var nextButton: UIButton!

    var player = YouTubePlayer.sharedInstance

    //var video: Video!

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.None

        player.delegate = self
        player.startPlaying()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        configure(navigationItem: navigationItem)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configure(#navigationItem: UINavigationItem) {
        let video = player.playlist.currentVideo()
        navigationItem.title = video.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addVideoToFavorite")
        navigationItem.rightBarButtonItem = addButton
    }

    // MARK: - Actions
    func tapPlayButton(button: UIButton) {
        if player.isPlaying() {
            player.pause()
            playButton.setImage(UIImage(named: "ic_play_circle_fill_48px"), forState: .Normal)
        } else {
            player.play()
            playButton.setImage(UIImage(named: "ic_pause_circle_fill_48px"), forState: .Normal)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension YouTubePlayerViewController: YouTubePlayerDelegate {

    func mediaIsPreparedToPlayDidChange(controller: MPMoviePlayerController) {
        controller.view.frame = videoView.bounds
        controller.duration
        videoView.addSubview(controller.view)
    }

}