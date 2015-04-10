//
//  ChannelViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/25.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import Async
import SwiftyUserDefaults

class ChannelViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle(NSLocalizedString("Videos", comment: "Videos"), forSegmentAtIndex: 0)
            segmentedControl.setTitle(NSLocalizedString("Playlists", comment: "Playlists"), forSegmentAtIndex: 1)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        }
    }

    @IBOutlet var videosView: UIView!
    @IBOutlet var playlistsView: UIView!

    var containerViews: [UIView] = []

    var channel: Channel! {
        didSet {
            parameters = ["channelId": channel.id, "order": "date"]
        }
    }
    var parameters: [String: String] = [:]

    var navigatable = false

    convenience init() {
        self.init(nibName: "ChannelViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        /*
        let videosViewController = VideosViewController()
        videosViewController.parameters = parameters
        videosViewController.navigatable = navigatable
        videosViewController.channel = channel
        addChildViewController(videosViewController)
        videosView.addSubview(videosViewController.view)
        videosViewController.view.frame = videosView.bounds

        let playlistsViewController = PlaylistsViewController()
        playlistsViewController.parameters = parameters
        playlistsViewController.navigatable = navigatable
        playlistsViewController.channel = channel
        addChildViewController(playlistsViewController)
        playlistsView.addSubview(playlistsViewController.view)
        playlistsViewController.view.frame = playlistsView.bounds
        */

        configure(videosView: videosView)
        configure(playlistsView: playlistsView)
        containerViews = [videosView, playlistsView]

        segmentChanged(segmentedControl)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if navigatable {
            navigationController?.setNavigationBarHidden(false, animated: true)
            configure(navigationItem: navigationItem)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = channel.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        Bookmark.exists(id: channel.id) { (result) in
            let bookmarkButton: UIBarButtonItem = {
                switch result {
                case .Success(let box):
                    if box.unbox {
                        return UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromBookmark")
                    } else {
                        return UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addChannelToBookmark")
                    }
                case .Failure(let box):
                    return UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addChannelToBookmark")
                }
            }()
            self.navigationItem.rightBarButtonItem = bookmarkButton
        }
    }

    func configure(videosView view: UIView) {
        let controller = VideosViewController()
        controller.channel = channel
        controller.parameters = parameters
        controller.navigatable = navigatable
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
    }

    func configure(playlistsView view: UIView) {
        let controller = PlaylistsViewController()
        controller.channel = channel
        controller.parameters = parameters
        controller.navigatable = navigatable
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
        view.hidden = true
    }

    func segmentChanged(sender: UISegmentedControl) {
        for view in containerViews {
            view.hidden = true
        }
        containerViews[sender.selectedSegmentIndex].hidden = false
        switch sender.selectedSegmentIndex {
        case 0:
            if let controller = childViewControllers[sender.selectedSegmentIndex] as? VideosViewController {
                if controller.items.count == 0 {
                    controller.parameters = parameters
                    controller.search()
                    //controller.search(parameters: parameters)
                }
            }
        case 1:
            if let controller = childViewControllers[sender.selectedSegmentIndex] as? PlaylistsViewController {
                if controller.items.count == 0 {
                    controller.parameters = parameters
                    controller.search()
                    //controller.search(parameters: parameters)
                }
            }
        default:
            break
        }
    }

    func addChannelToBookmark() {
        Bookmark.count { (result) in
            switch result {
            case .Success(let box):
                let count = box.unbox
                if count < Defaults["maxNumberOfSubscribes"].int! {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    Bookmark.add(self.channel) { (result) in
                        self.navigationItem.rightBarButtonItem?.enabled = false
                        switch result {
                        case .Success(let box):
                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToBookmarksNotification, object: self, userInfo: ["item": self.channel]))
                            Async.main {
                                let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
                                self.navigationItem.rightBarButtonItem = bookmarkButton
                            }
                        case .Failure(let box):
                            let error = box.unbox
                            self.logger.error(error.localizedDescription)
                            Alert.error(error)
                        }
                    }
                } else {
                    let message = NSLocalizedString("Cannot subscribe to any more Channel", comment: "これ以上のチャンネルやプレイリストを登録できません。")
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismis", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            case .Failure(let box):
                let error = box.unbox
                self.logger.error(error.localizedDescription)
                Alert.error(error)
            }
        }
    }

    func removeFromBookmark() {
        // TODO:
    }
}
