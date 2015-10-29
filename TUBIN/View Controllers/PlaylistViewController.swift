//
//  PlaylistViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/25.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

import YouTubeKit

import Alamofire
import SwiftyUserDefaults
import XCGLogger

class PlaylistViewController: ItemsViewController {

    var channel: Channel?
    var showChannel = true

    var playlist: Playlist! {
        didSet {
            parameters = ["playlistId": playlist.id]
        }
    }
    /*
    var playlist: (id: String, title: String, thumbnailURL: String, channelId: String?)! {
        didSet {
            parameters = ["playlistId":playlist.id]
        }
    }
    */

    @IBOutlet var channelView: ChannelView!

    convenience init() {
        self.init(nibName: "PlaylistViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayerDidPrepareToPlay:", name: VideoPlayerDidPrepareToPlayNotification, object: nil)
        search()
        configure(channelView: channelView)
    }

    override func configure(navigationItem navigationItem: UINavigationItem) {
        super.configure(navigationItem: navigationItem)
        navigationItem.title = playlist.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = {
            if Bookmark.exists(type: "playlist", id: self.playlist.id) {
                return UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromBookmark")
            } else {
                return UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addPlaylistToBookmark")
            }
        }()
        /*
        Bookmark.exists(id: playlist.id) { (result) in
            switch result {
            case .Success(let box):
                if box.value {
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
        */
    }

    override func configure(tableView tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
    }

    func configure(channelView channelView: ChannelView) {
        if !showChannel {
            channelView.height.constant = 0
            return
        }
        if let channel = channel {
            if channel.id == playlist.channelId {
                channelView.height.constant = 0
                return
            }
        } else {
            YouTubeKit.search(parameters: ["channelId": playlist.channelId]) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let value):
                    if let channel = value.items.first {
                        self.channel = channel
                        let controller = ChannelsViewController()
                        controller.parameters = ["channelId": channel.id]
                        controller.items = [channel]
                        controller.navigatable = self.navigatable
                        self.addChildViewController(controller)
                        self.channelView.addSubview(controller.view)
                        controller.view.frame = self.channelView.bounds
                    }
                case .Failure(let error):
                    break
                }
            }
        }
    }

    // MARK: - YouTube search
    override func search() {
        super.search()
        YouTubeKit.playlistItems(parameters: parameters) { (result: Result<(page: Page, items: [Video]), NSError>) -> Void in
            switch result {
            case .Success(let value):
                self.searchCompletion(page: value.page, items: value.items)
            case .Failure(let error):
                self.errorCompletion(error)
            }
        }
    }

    override func searchMore() {
        super.searchMore()
        YouTubeKit.playlistItems(parameters: parameters) { (result: Result<(page: Page, items: [Video]), NSError>) -> Void in
            switch result {
            case .Success(let value):
                self.searchMoreCompletion(page: value.page, items: value.items)
            case .Failure(let error):
                self.errorCompletion(error)
            }
        }
    }

    // MARK: Bookmark
    func addPlaylistToBookmark() {
        navigationItem.rightBarButtonItem?.enabled = true
        Bookmark.add(playlist)
        navigationItem.rightBarButtonItem?.enabled = false
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddToBookmarksNotification, object: self, userInfo: ["item": self.playlist]))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        /*
        Bookmark.add(playlist) { (result) in
            self.navigationItem.rightBarButtonItem?.enabled = false
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddToBookmarksNotification, object: self, userInfo: ["item": self.playlist]))
                Async.main {
                    let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
                    self.navigationItem.rightBarButtonItem = bookmarkButton
                }
            case .Failure(let box):
                let error = box.value
                self.logger.error(error.localizedDescription)
                Alert.error(box.value)
            }
        }
        */
    }

    func removeFromBookmark() {
    }

}

extension PlaylistViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
            let item = items[indexPath.row] as! Video
            cell.configure(item)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as! LoadMoreTableViewCell
            cell.button.addTarget(self, action: "searchMore", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
        controller.video = items[indexPath.row] as! Video
        controller.playlist = items as! [Video]
        controller.channel = channel
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}