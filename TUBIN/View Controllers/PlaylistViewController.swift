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
import SVProgressHUD

class PlaylistViewController: ItemsViewController {

    let videoPlayer = VideoPlayer.sharedInstance

    var playlist: Playlist! {
        didSet {
            parameters = ["playlistId": playlist.id]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidPrepareToPlay:", name: VideoPlayerDidPrepareToPlayNotification, object: nil)
        search()
    }

    override func configure(#navigationItem: UINavigationItem) {
        super.configure(navigationItem: navigationItem)
        navigationItem.title = playlist.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPlaylistToBookmark")
        navigationItem.rightBarButtonItem = addButton
    }

    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
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
        Bookmark.add(playlist) { (result) in
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToBookmarksNotification, object: self, userInfo: ["item": self.playlist]))
            case .Failure(let box):
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
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
}