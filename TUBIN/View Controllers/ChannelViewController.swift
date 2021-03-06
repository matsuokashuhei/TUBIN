//
//  ChannelViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/25.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import SwiftyUserDefaults
import XCGLogger

class ChannelViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle(NSLocalizedString("Videos", comment: "Videos"), forSegmentAtIndex: 0)
            segmentedControl.setTitle(NSLocalizedString("Playlists", comment: "Playlists"), forSegmentAtIndex: 1)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        }
    }

    @IBOutlet weak var videosView: UIView!
    @IBOutlet weak var playlistsView: UIView!
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

    func configure(navigationItem navigationItem: UINavigationItem) {
        navigationItem.title = channel.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = {
            if Bookmark.exists(type: "channel", id: self.channel.id) {
                return UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromBookmark")
            } else {
                return UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addChannelToBookmark")
            }
        }()
    }

    func configure(videosView view: UIView) {
        let controller = VideosViewController()
        controller.channel = channel
        controller.parameters = parameters
        controller.navigatable = navigatable
        addChildViewController(controller)
    }

    func configure(playlistsView view: UIView) {
        let controller = PlaylistsViewController()
        controller.channel = channel
        controller.parameters = parameters
        controller.navigatable = navigatable
        addChildViewController(controller)
    }

    func segmentChanged(sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        if let controller = childViewControllers[selectedSegmentIndex] as? ItemsViewController {
            for (index, view) in containerViews.enumerate() {
                view.hidden = index != selectedSegmentIndex
                if view.hidden {
                    (view.subviews as NSArray).enumerateObjectsUsingBlock { (view, index, stop) in
                        view.removeFromSuperview()
                    }
                } else {
                    view.addSubview(controller.view)
                    controller.view.frame = view.bounds
                    if controller.items.count == 0 {
                        controller.search()
                    }
                }
            }
        }
    }

    func addChannelToBookmark() {
        navigationItem.rightBarButtonItem?.enabled = true
        Bookmark.add(channel)
        navigationItem.rightBarButtonItem?.enabled = false
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddToBookmarksNotification, object: self, userInfo: ["item": self.channel]))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        /*
        Bookmark.add(channel) { (result) in
            self.navigationItem.rightBarButtonItem?.enabled = false
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddToBookmarksNotification, object: self, userInfo: ["item": self.channel]))
                Async.main {
                    let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
                    self.navigationItem.rightBarButtonItem = bookmarkButton
                }
            case .Failure(let box):
                let error = box.value
                self.logger.error(error.localizedDescription)
                Alert.error(error)
            }
        }
        */
    }

    func removeFromBookmark() {
    }

}
