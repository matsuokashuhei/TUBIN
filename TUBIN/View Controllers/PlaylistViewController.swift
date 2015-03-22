//
//  PlaylistViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/25.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import LlamaKit

class PlaylistViewController: ItemsViewController {

    let videoPlayer = VideoPlayer.sharedInstance

    var channel: Channel?

    var playlist: Playlist! {
        didSet {
            parameters = ["playlistId": playlist.id]
        }
    }

    @IBOutlet var channelView: ChannelView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidPrepareToPlay:", name: VideoPlayerDidPrepareToPlayNotification, object: nil)
        search()
        configure(channelView: channelView)
    }

    override func configure(#navigationItem: UINavigationItem) {
        super.configure(navigationItem: navigationItem)
        navigationItem.title = playlist.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        Bookmark.exists(id: playlist.id) { (result) in
            switch result {
            case .Success(let box):
                if box.unbox {
                    let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromBookmark")
                    self.navigationItem.rightBarButtonItem = bookmarkButton
                } else {
                    let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addPlaylistToBookmark")
                    self.navigationItem.rightBarButtonItem = bookmarkButton
                }
            case .Failure(let box):
                let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addPlaylistToBookmark")
                self.navigationItem.rightBarButtonItem = bookmarkButton
            }
        }
    }

    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
    }

    func configure(#channelView: ChannelView) {
        if let channel = channel {
            if channel.id == playlist.channelId {
                channelView.height.constant = 0
                return
            }
        } else {
            YouTubeKit.search(parameters: ["channelId": playlist.channelId]) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    if let channel = box.unbox.items.first {
                       self.channel = channel
                    }
                case .Failure(let box):
                    break
                }
            }
        }
        let controller = ChannelsViewController(nibName: "ChannelsViewController", bundle: NSBundle.mainBundle())
        controller.search(parameters: ["channelId": playlist.channelId])
        controller.navigatable = navigatable
        controller.view.frame = channelView.bounds
        addChildViewController(controller)
        channelView.addSubview(controller.view)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVideo" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as VideoPlayerViewController
                let video = items[indexPath.row] as Video
                if let playlist = videoPlayer.playlist {
                    if video.id == playlist.playingVideo().id {
                        destinationViewController.playingVideo = .NowPlaying
                    }
                }
                videoPlayer.setPlaylist(videos: items as [Video], index: indexPath.row)
            }
        }
    }

    // MARK: - YouTube search
    override func search() {
        super.search()
        YouTubeKit.playlistItems(parameters: parameters) { (result: Result<(page: Page, items: [Video]), NSError>) -> Void in
            switch result {
            case .Success(let box):
                self.searchCompletion(page: box.unbox.page, items: box.unbox.items)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }

    override func searchMore() {
        super.searchMore()
        YouTubeKit.playlistItems(parameters: parameters) { (result: Result<(page: Page, items: [Video]), NSError>) -> Void in
            switch result {
            case .Success(let box):
                self.searchMoreCompletion(page: box.unbox.page, items: box.unbox.items)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }

    // MARK: Bookmark
    func addPlaylistToBookmark() {
        navigationItem.rightBarButtonItem?.enabled = true
        Bookmark.add(playlist) { (result) in
            self.navigationItem.rightBarButtonItem?.enabled = false
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToBookmarksNotification, object: self, userInfo: ["item": self.playlist]))
                Async.main {
                    let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
                    self.navigationItem.rightBarButtonItem = bookmarkButton
                }
            case .Failure(let box):
                Alert.error(box.unbox)
            }
        }
    }

    func removeFromBookmark() {
        // TODO:
    }

    // MARK: Notifications
    func videoPlayerDidPrepareToPlay(notification: NSNotification) {
        let video = VideoPlayer.sharedInstance.playlist.playingVideo()
        let index = NSArray(array: items).indexOfObject(video)
        tableView.selectRowAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: true, scrollPosition: .Middle)
    }
}

extension PlaylistViewController: UITableViewDataSource {

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

extension PlaylistViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        //let controller = YouTubePlayerViewController(nibName: "YouTubePlayerViewController_Phone", bundle: NSBundle.mainBundle())
        let controller: YouTubePlayerViewController = {
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                return YouTubePlayerViewController(nibName: "YouTubePlayerViewController_Phone", bundle: NSBundle.mainBundle())
            } else {
                return YouTubePlayerViewController(nibName: "YouTubePlayerViewController_Pad", bundle: NSBundle.mainBundle())
            }
        }()
        controller.video = items[indexPath.row] as Video
        controller.playlist = items as [Video]
        controller.channel = channel
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
    }

}