//
//  ChannelViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/25.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import SVProgressHUD

class ChannelViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBOutlet var videosView: UIView! /*{
        didSet {
            let controller = VideosViewController(nibName: "VideosViewController", bundle: NSBundle.mainBundle())
            addChildViewController(controller)
            videosView.addSubview(controller.view)
            controller.view.frame = videosView.bounds
        }
    }*/
    @IBOutlet var playlistsView: UIView! /*{
        didSet {
            let controller = PlaylistsViewController(nibName: "PlaylistsViewController", bundle: NSBundle.mainBundle())
            addChildViewController(controller)
            playlistsView.addSubview(controller.view)
            controller.view.frame = playlistsView.bounds
        }
    }*/

    var containerViews: [UIView] = []

    var channel: Channel! {
        didSet {
            parameters = ["channelId": channel.id, "order": "date"]
        }
    }
    var parameters: [String: String] = [:]

    var navigatable = false

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.None

        let videosViewController = VideosViewController(nibName: "VideosViewController", bundle: NSBundle.mainBundle())
        videosViewController.parameters = parameters
        videosViewController.navigatable = navigatable
        addChildViewController(videosViewController)
        videosView.addSubview(videosViewController.view)

        let playlistsViewController = PlaylistsViewController(nibName: "PlaylistsViewController", bundle: NSBundle.mainBundle())
        playlistsViewController.parameters = parameters
        playlistsViewController.navigatable = navigatable
        addChildViewController(playlistsViewController)
        playlistsView.addSubview(playlistsViewController.view)

        containerViews = [videosView, playlistsView]

        configure(segmentedControl)
        segmentChanged(segmentedControl)

        /*
        if let videosViewController = childViewControllers[0] as? VideosViewController {
            //videosViewController.searchItems(parameters: ["channelId": self.channel.id, "order": "date"])
            videosViewController.parameters = parameters
        }
        if let playlistsViewController = childViewControllers[1] as? PlaylistsViewController {
            playlistsViewController.parameters = parameters
            //playlistsViewController.searchItems(parameters: ["channelId": self.channel.id, "order": "date"])
        }
        */
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
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addChannelToBookmark")
        navigationItem.rightBarButtonItem = addButton
    }

    func configure(segmentedControl: UISegmentedControl) {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        for view in containerViews {
            view.hidden = true
        }
        containerViews[sender.selectedSegmentIndex].hidden = false
        switch sender.selectedSegmentIndex {
        case 0:
            if let videosViewController = childViewControllers[sender.selectedSegmentIndex] as? VideosViewController {
                if videosViewController.items.count == 0 {
                    videosViewController.search(parameters: parameters)
                }
            }
        case 1:
            if let playlistsViewController = childViewControllers[sender.selectedSegmentIndex] as? PlaylistsViewController {
                if playlistsViewController.items.count == 0 {
                    playlistsViewController.search(parameters: parameters)
                }
            }
        default:
            break
        }
    }

    func addChannelToBookmark() {
        Bookmark.add(channel) { (result) in
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToBookmarksNotification, object: self, userInfo: ["item": self.channel]))
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
    }
}
