//
//  VideosViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import LlamaKit

class VideosViewController: ItemsViewController {

    var channel: Channel?

    convenience override init() {
        self.init(nibName: "VideosViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge.None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidPrepareToPlay:", name: VideoPlayerDidPrepareToPlayNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
    }

    // MARK: - YouTube search

    override func search() {
        super.search()
        if let chart = parameters["chart"] {
            videos()
        } else {
            YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Video]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchCompletion(page: box.unbox.page, items: box.unbox.items)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        }
    }

    override func searchMore() {
        super.searchMore()
        if let chart = parameters["chart"] {
            moreVideos()
        } else {
            YouTubeKit.search(parameters: parameters) { (response: Result<(page: Page, items: [Video]), NSError>) -> Void in
                switch response {
                case .Success(let box):
                    self.searchMoreCompletion(page: box.unbox.page, items: box.unbox.items)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        }
    }

    func videos(#parameters: [String: String]) {
        super.search(parameters: parameters)
        videos()
    }

    func videos() {
        YouTubeKit.videos(parameters: parameters) { (result) in
            switch result {
            case .Success(let box):
                self.searchCompletion(page: box.unbox.page, items: box.unbox.videos)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }

    func moreVideos() {
        YouTubeKit.videos(parameters: parameters) { (result) in
            switch result {
            case .Success(let box):
                self.searchMoreCompletion(page: box.unbox.page, items: box.unbox.videos)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }

    // MARK: Notification
    func videoPlayerDidPrepareToPlay(notification: NSNotification) {
        let video = YouTubePlayer.sharedInstance.nowPlaying
        let index = NSArray(array: items).indexOfObject(video)
        tableView.selectRowAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: true, scrollPosition: .Middle)
    }

}

extension VideosViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            var cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as VideoTableViewCell
            let item = items[indexPath.row] as Video
            cell.configure(item)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as LoadMoreTableViewCell
            cell.button.addTarget(self, action: "searchMore", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }

}

extension VideosViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
        controller.video = items[indexPath.row] as Video
        controller.playlist = items as [Video]
        controller.channel = channel
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
    }

}