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

    var channel: Channel?

    var playlist: Playlist! {
        didSet {
            parameters = ["playlistId": playlist.id]
        }
    }

    @IBOutlet var channelView: ChannelView!

    convenience override init() {
        self.init(nibName: "PlaylistViewController", bundle: NSBundle.mainBundle())
    }

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
        let controller = ChannelsViewController()
        controller.search(parameters: ["channelId": playlist.channelId])
        controller.navigatable = navigatable
        controller.view.frame = channelView.bounds
        addChildViewController(controller)
        channelView.addSubview(controller.view)
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
        Bookmark.count { (result)in
            switch result {
            case .Success(let box):
                if box.unbox < Configration.Defaults.maxNumberOfSubscribes {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    Bookmark.add(self.playlist) { (result) in
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
                } else {
                    let alert = UIAlertController(title: nil, message: "Cannot subscribe to any more Playlist", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismis", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            case .Failure(let box):
                Alert.error(box.unbox)
            }
        }
    }

    func removeFromBookmark() {
        // TODO:
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
        let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
        controller.video = items[indexPath.row] as Video
        controller.playlist = items as [Video]
        controller.channel = channel
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
    }

}