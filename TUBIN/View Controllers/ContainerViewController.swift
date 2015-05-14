//
//  ContainerViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/04.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import Result
import Box
import Async
import XCGLogger

class ContainerViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var tabBar: TabBar! {
        didSet {
            tabBar.delegate = self
        }
    }

    @IBOutlet weak var containerView: ContainerView! {
        didSet {
            containerView.delegate = self
        }
    }

    var bookmarks = [Bookmark]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // ------------------
        // Bookmarkの取得
        // ------------------
        loadBookmarks()
        tabBar.selectTabAtIndex(0)
        containerView.selectViewAtIndex(0)
        // ------------------
        // Notificationの設定
        // ------------------
        // Bookmark
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addToBookmarks:", name: AddToBookmarksNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadBookmarks:", name: BookmarksEditedNotification, object: nil)
        // Theme
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchTheme:", name: SwitchThemeNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        }
        super.viewWillAppear(animated)
    }

    func loadBookmarks() {
        let result = Bookmark.all()
        switch result {
        case .Success(let box):
            bookmarks = box.value
        case .Failure(let box):
            let error = box.value
            self.logger.error(error.localizedDescription)
            Alert.error(error)
            return
        }
        for (index, bookmark) in enumerate(bookmarks) {
            let controller: UIViewController? = {
                switch bookmark.name {
                case "playlist":
                    let playlist = bookmark.item as! Playlist
                    self.tabBar.add(playlist)
                    let controller = PlaylistViewController()
                    controller.playlist = playlist
                    return controller
                case "channel":
                    let channel = bookmark.item as! Channel
                    self.tabBar.add(channel)
                    let controller = ChannelViewController()
                    controller.channel = channel
                    return controller
                case "collection":
                    let collection = bookmark.collection!
                    self.tabBar.add(collection)
                    let controller = CollectionViewController()
                    controller.collection = collection
                    return controller
                case "popular":
                    self.tabBar.add("Popular")
                    let controller = PopularViewController()
                    return controller
                case "guide":
                    self.tabBar.add("Guide")
                    let controller = GuideCategoriesViewController()
                    return controller
                case "favorites":
                    self.tabBar.add("Favorites")
                    let controller = UserViewController()
                    return controller
                case "search":
                    self.tabBar.add("Search")
                    let controller = SearchViewController()
                    return controller
                case "music":
                    self.tabBar.add("Music")
                    let controller = MusicViewController()
                    return controller
                default:
                    return nil
                }
            }()
            if let controller = controller {
                self.addChildViewController(controller)
                self.containerView.add(view: controller.view)
            }
        }
        tabBar.add(NSLocalizedString("Settings", comment: "Settings"))
        let controller = SettingsViewController()
        addChildViewController(controller)
        containerView.add(view: controller.view)
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let index = tabBar.indexOfSelectedTab()
        containerView.selectViewAtIndex(index)
        //containerView.scrollToIndexOfContentViews(index)
    }


    func clearBookmarks() {
        for childViewController in childViewControllers {
            childViewController.removeFromParentViewController()
        }
        tabBar.clearTabs()
        containerView.clearViews()
    }

}

extension ContainerViewController {

    // Notification

    func reloadBookmarks(notfication: NSNotification) {
        containerView.delegate = nil
        tabBar.delegate = nil
        clearBookmarks()
        loadBookmarks()
        /*
        Async.main {
            self.tabBar.setNeedsLayout()
            self.tabBar.layoutIfNeeded()
            self.containerView.setNeedsLayout()
            self.containerView.layoutIfNeeded()
        }
        */
//        let lastIndex = containerView.views.count - 1
//        tabBar.selectTabAtIndex(lastIndex)
//        containerView.selectViewAtIndex(lastIndex)
        containerView.delegate = self
        tabBar.delegate = self
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        let lastIndex = containerView.views.count - 1
        tabBar.selectTabAtIndex(lastIndex)
        containerView.selectViewAtIndex(lastIndex)
    }

    func addToBookmarks(notification: NSNotification) {
        if let item = notification.userInfo?["item"] as? Item {
            Toast.addToBookmarks(item: item)
        }
        Bookmark.all(skip: bookmarks.count) { (result) -> Void in
            switch result {
            case .Success(let box):
                for bookmark in box.value {
                    let controller: UIViewController? = {
                        switch bookmark.name {
                        case "playlist":
                            let playlist = bookmark.item as! Playlist
                            self.tabBar.add(playlist, index: self.bookmarks.count)
                            let controller = PlaylistViewController()
                            controller.playlist = playlist
                            return controller
                        case "channel":
                            let channel = bookmark.item as! Channel
                            self.tabBar.add(channel, index: self.bookmarks.count)
                            let controller = ChannelViewController()
                            controller.channel = channel
                            return controller
                        case "collection":
                            let collection = bookmark.collection!
                            self.tabBar.add(collection, index: self.bookmarks.count)
                            let controller = CollectionViewController()
                            controller.collection = collection
                            return controller
                        default:
                            return nil
                        }
                    }()
                    if let controller = controller {
                        self.addChildViewController(controller)
                        self.containerView.add(view: controller.view, index: self.bookmarks.count)
                        self.bookmarks.append(bookmark)
                    }
                }
                self.tabBar.setNeedsLayout()
                self.tabBar.layoutIfNeeded()
                self.containerView.setNeedsLayout()
                self.containerView.layoutIfNeeded()
            case .Failure(let box):
                let error = box.value
                self.logger.error(error.localizedDescription)
                Alert.error(error)
            }
        }
    }

    func switchTheme(notification: NSNotification) {
        reloadBookmarks(notification)
    }
}

extension ContainerViewController: TabBarDelegate {

    func tabBar(tabBar: TabBar, didSelectTabAtIndex index: Int) {
        containerView.delegate = nil
        containerView.selectViewAtIndex(index)
        containerView.delegate = self
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: HideKeyboardNotification, object: self))
    }

}

extension ContainerViewController: ContainerViewDelegate {

    func containerView(containerView: ContainerView, indexOfContentViews index: Int) {
        tabBar.selectTabAtIndex(index)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: HideKeyboardNotification, object: self))
    }

    func containerViewDidScroll(contentOffsetX: CGFloat, contentSizeWidth: CGFloat) {
        tabBar.syncScroll(contentOffsetX: contentOffsetX, contentSizeWidth: contentSizeWidth)
    }
}
