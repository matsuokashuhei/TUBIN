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
        // Bookmark
        loadBookmarks()
        selectBookmarkAtIndex(0)
        // Bookmark
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addToBookmarks:", name: AddToBookmarksNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadBookmarks:", name: BookmarksEditedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchTheme:", name: SwitchThemeNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        }
        super.viewWillAppear(animated)
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let index = tabBar.indexOfSelectedTab()
        containerView.selectViewAtIndex(index)
    }
}

// MARK: - Realm
extension ContainerViewController {

    func fetch() {
        bookmarks = Bookmark.all()
    }

}

// MARK: - Bookmarks
extension ContainerViewController {

    func loadBookmarks() {
        fetch()
        for bookmark in bookmarks {
            let controller: UIViewController? = {
                switch bookmark.type {
                case "playlist":
                    if let playlist = bookmark.playlist {
                        self.tabBar.add(playlist)
                        let controller = PlaylistViewController()
                        controller.playlist = playlist
                        return controller
                    } else {
                        return nil
                    }
                case "channel":
                    if let channel = bookmark.channel {
                        self.tabBar.add(channel)
                        let controller = ChannelViewController()
                        controller.channel = channel
                        return controller
                    } else {
                        return nil
                    }
                case "popular":
                    self.tabBar.add(bookmark.title)
                    let controller = PopularViewController()
                    return controller
                case "guide":
                    self.tabBar.add(bookmark.title)
                    let controller = GuideCategoriesViewController()
                    return controller
                case "favorite":
                    self.tabBar.add(bookmark.title)
                    let controller = UserViewController()
                    return controller
                case "search":
                    self.tabBar.add(bookmark.title)
                    let controller = SearchViewController()
                    return controller
                case "music":
                    self.tabBar.add(bookmark.title)
                    let controller = MusicViewController()
                    return controller
                default:
                    return nil
                }
            }()
            if let controller = controller {
                addChildViewController(controller)
                containerView.add(view: controller.view)
            }
        }
        tabBar.add(NSLocalizedString("Settings", comment: "Settings"))
        let controller = SettingsViewController()
        addChildViewController(controller)
        containerView.add(view: controller.view)
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }

}

// MARK: - Child views editing
extension ContainerViewController {

    func removeBookmarks() {
        containerView.delegate = nil
        tabBar.delegate = nil
        for childViewController in childViewControllers {
            childViewController.removeFromParentViewController()
        }
        tabBar.clearTabs()
        containerView.clearViews()
        containerView.delegate = self
        tabBar.delegate = self
    }

    func selectBookmarkAtIndex(index: Int) -> () {
        tabBar.selectTabAtIndex(index)
        containerView.selectViewAtIndex(index)
    }

}

// MARK: - Notifications
extension ContainerViewController {

    func reloadBookmarks(notfication: NSNotification) {
        removeBookmarks()
        loadBookmarks()
        let lastIndex = containerView.views.count - 1
        selectBookmarkAtIndex(lastIndex)
    }

    func addToBookmarks(notification: NSNotification) {
        if let item = notification.userInfo?["item"] as? Item {
            Toast.addToBookmarks(item: item)
        }
        for bookmark in (Bookmark.all().filter { (bookmark) -> Bool in bookmark.index > self.bookmarks.count }) {
            let controller: UIViewController? = {
                switch bookmark.type {
                case "playlist":
                    if let playlist = bookmark.playlist {
                        self.tabBar.add(playlist, index: self.bookmarks.count)
                        let controller = PlaylistViewController()
                        controller.playlist = playlist
                        return controller
                    } else {
                        return nil
                    }
                case "channel":
                    if let channel = bookmark.channel {
                        self.tabBar.add(channel, index: self.bookmarks.count)
                        let controller = ChannelViewController()
                        controller.channel = channel
                        return controller
                    } else {
                        return nil
                    }
                default:
                    return nil
                }
            }()
            if let controller = controller {
                addChildViewController(controller)
                containerView.add(view: controller.view, index: self.bookmarks.count)
                bookmarks.append(bookmark)
            }
        }
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }

    func switchTheme(notification: NSNotification) {
        reloadBookmarks(notification)
    }
}

// MARK: - Tab bar delegate
extension ContainerViewController: TabBarDelegate {

    func tabBar(tabBar: TabBar, didSelectTabAtIndex index: Int) {
        logger.verbose("index: \(index)")
        containerView.delegate = nil
        containerView.selectViewAtIndex(index)
        containerView.delegate = self
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: HideKeyboardNotification, object: self))
    }

}

// MARK: - Container view delegate
extension ContainerViewController: ContainerViewDelegate {

    func containerView(containerView: ContainerView, indexOfContentViews index: Int) {
        tabBar.selectTabAtIndex(index)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: HideKeyboardNotification, object: self))
    }

    func containerViewDidScroll(contentOffsetX: CGFloat, contentSizeWidth: CGFloat) {
        tabBar.syncScroll(contentOffsetX: contentOffsetX, contentSizeWidth: contentSizeWidth)
    }
}
