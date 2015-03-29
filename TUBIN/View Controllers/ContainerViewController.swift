//
//  ContainerViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/04.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import LlamaKit
import SVProgressHUD

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
        // ------------------
        // Notificationの設定
        // ------------------
        // Bookmark
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addItemToBookmarks:", name: AddItemToBookmarksNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadBookmarks:", name: BookmarksEditedNotification, object: nil)
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
            bookmarks = box.unbox
        case .Failure(let box):
            let error = box.unbox
            self.logger.error(error.localizedDescription)
            Alert.error(error)
            return
        }
        for bookmark in bookmarks {
            let controller: UIViewController? = {
                switch bookmark.name {
                case "playlist":
                    let playlist = bookmark.item as Playlist
                    self.tabBar.add(item: playlist)
                    let controller = PlaylistViewController()
                    controller.playlist = playlist
                    return controller
                case "channel":
                    let channel = bookmark.item as Channel
                    self.tabBar.add(item: channel)
                    let controller = ChannelViewController()
                    controller.channel = channel
                    return controller
                case "Popular":
                    self.tabBar.add(text: bookmark.name)
                    let controller = PopularViewController()
                    return controller
                case "Guide":
                    self.tabBar.add(text: bookmark.name)
                    let controller = GuideCategoriesViewController()
                    return controller
                case "Favorites":
                    self.tabBar.add(text: bookmark.name)
                    //let controller = FavoritesViewController()
                    let controller = UserViewController()
                    return controller
                case "Search":
                    self.tabBar.add(text: bookmark.name)
                    let controller = SearchViewController()
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
        tabBar.add(text: "Settings")
        let controller = SettingsViewController()
        addChildViewController(controller)
        containerView.add(view: controller.view)
        if let tab = self.tabBar.tabs.first {
            self.tabBar.selectTab(tab)
        }
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let index = tabBar.indexOfSelectedTab()
        containerView.scrollToIndexOfContentViews(index)
    }


    func resetBookmarks() {
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
        resetBookmarks()
        loadBookmarks()
        //Async.main {
            self.tabBar.setNeedsLayout()
            self.tabBar.layoutIfNeeded()
            self.containerView.setNeedsLayout()
            self.containerView.layoutIfNeeded()
            self.tabBar.selectTabAtIndex(self.containerView.views.count)
        //}
        SVProgressHUD.showSuccessWithStatus("")
    }

    func addItemToBookmarks(notification: NSNotification) {
        logger.debug("bookmarks.count: \(bookmarks.count)")
        if let item = notification.userInfo?["item"] as? Item {
            Toast.bookmark(item: item)
        }
        Bookmark.all(skip: bookmarks.count) { (result) -> Void in
            switch result {
            case .Success(let box):
                for bookmark in box.unbox {
                    let controller: UIViewController? = {
                        switch bookmark.name {
                        case "playlist":
                            let playlist = bookmark.item as Playlist
                            self.tabBar.add(item: playlist, index: self.bookmarks.count)
                            let controller = PlaylistViewController()
                            controller.playlist = playlist
                            return controller
                        case "channel":
                            let channel = bookmark.item as Channel
                            self.tabBar.add(item: channel, index: self.bookmarks.count)
                            let controller = ChannelViewController()
                            controller.channel = channel
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
                let error = box.unbox
                self.logger.error(error.localizedDescription)
                Alert.error(error)
            }
        }
    }

}

extension ContainerViewController: TabBarDelegate {

    func tabBar(tabBar: TabBar, didSelectTabAtIndex index: Int) {
        containerView.delegate = nil
        containerView.scrollToIndexOfContentViews(index)
        containerView.delegate = self
    }

}

extension ContainerViewController: ContainerViewDelegate {

    func containerView(containerView: ContainerView, indexOfContentViews index: Int) {
        tabBar.selectTabAtIndex(index)
    }

    func containerViewDidScroll(scrollView: UIScrollView) {
        tabBar.syncContentOffset(scrollView)
    }
}
