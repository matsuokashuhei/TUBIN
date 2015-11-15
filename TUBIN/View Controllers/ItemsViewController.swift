//
//  ItemsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
//import AsyncSwift
import GCDKit
import Result
import XCGLogger

class ItemsViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var tableView: UITableView!

    let refreshControll = UIRefreshControl()

    var items: [Item] = []

    var parameters = [String: String]()

    var navigatable = false

    var spinnable = true

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(tableView: tableView)

        refreshControll.addTarget(self, action: "pullToRefresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControll)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if navigatable {
            configure(navigationItem: navigationItem)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTouched:", name: StatusBarTouchedNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StatusBarTouchedNotification, object: nil)
    }

    func configure(navigationItem navigationItem: UINavigationItem) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    func configure(tableView tableView: UITableView) {
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        tableView.delegate = self

        // Add long press gesture to table view
        func createLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "onLongPressed:")
            longPressGestureRecognizer.allowableMovement = 15.0
            longPressGestureRecognizer.minimumPressDuration = 1.0
            return longPressGestureRecognizer
        }
        //tableView.addGestureRecognizer(createLongPressGestureRecognizer())

    }

    // MARK: - YouTube search

//    func search(#parameters: [String: String]) {
//        self.parameters = parameters
//        search()
//    }

    func search() {
        if spinnable {
            Spinner.show()
        }
    }

    func searchMore() {
        if spinnable {
            Spinner.show()
        }
    }

    func searchCompletion(page page: Page, items: [Item]) {
        logger.verbose("START")
        GCDBlock.async(.Default) {
        //Async.background {
            self.items = items
            if let next = page.next {
                self.parameters["pageToken"] = next
            }
        //}.main {
        }.notify(.Main) {
            self.refreshControll.endRefreshing()
            self.tableView.reloadData()
            if let _ = self.parameters["q"] {
                self.tableView.setContentOffset(CGPointZero, animated: false)
            }
            if self.spinnable {
                Spinner.dismiss()
            }
            self.logger.verbose("END")
        }
    }

    func searchMoreCompletion(page page: Page, items: [Item]) {
        //Async.background {
        GCDBlock.async(.Default) {
            if let next = page.next {
                self.parameters["pageToken"] = next
            } else {
                self.parameters.removeValueForKey("pageToken")
            }
            for item in items {
                self.items.append(item)
            }
        //}.main {
        }.notify(.Main) {
            self.refreshControll.endRefreshing()
            self.tableView.reloadData()
            if self.spinnable {
                Spinner.dismiss()
            }
        }
    }

    func errorCompletion(error: NSError) {
        logger.error(error.localizedDescription)
        self.refreshControll.endRefreshing()
        if spinnable {
            Spinner.dismiss()
        }
        logger.error(error.localizedDescription)
        Alert.error(error)
    }

    // MARK: - Actions

    func pullToRefresh() {
        parameters.removeValueForKey("pageToken")
        logger.debug("parameters: \(self.parameters)")
        if !parameters.values.isEmpty {
            spinnable = false
            search()
            spinnable = true
        } else {
            refreshControll.endRefreshing()
        }
        //refreshControll.endRefreshing()
    }

    func onLongPressed(sender: UILongPressGestureRecognizer) {

        /*
        if let video = longPressedItem(sender) as? Video {
            Favorite.add(video, handler: { (result) -> Void in
                switch result {
                case .Success(let box):
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddItemToFavoritesNotification, object: self, userInfo: ["item": video]))
                case .Failure(let box):
                    let error = box.value
                    self.logger.error(error.localizedDescription)
                    Alert.error(box.value)
                }
            })
            return
        }
        if let playlist = longPressedItem(sender) as? Playlist {
            Bookmark.add(playlist, handler: { (result) -> Void in
                switch result {
                case .Success(let box):
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddToBookmarksNotification, object: self, userInfo: ["item": playlist]))
                case .Failure(let box):
                    let error = box.value
                    self.logger.error(error.localizedDescription)
                    Alert.error(box.value)
                }
            })
            return
        }
        if let channel = longPressedItem(sender) as? Channel {
            Bookmark.add(channel, handler: { (result) -> Void in
                switch result {
                case .Success(let box):
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddToBookmarksNotification, object: self, userInfo: ["item": channel]))
                case .Failure(let box):
                    let error = box.value
                    self.logger.error(error.localizedDescription)
                    Alert.error(box.value)
                }
            })
            return
        }
        */
    }

    func longPressedItem(sender: UILongPressGestureRecognizer) -> Item? {
        let point = sender.locationInView(tableView)
        if let indexPath = tableView.indexPathForRowAtPoint(point) {
            if sender.state == UIGestureRecognizerState.Began {
                let item = items[indexPath.row]
                return item
            }
        }
        return nil
    }
}

extension ItemsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 {
            if let _ = parameters["pageToken"] {
                return items.count + 1
            }
        }
        return items.count
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: HideKeyboardNotification, object: self))
    }
}

extension ItemsViewController {

    func statusBarTouched(notification: NSNotification) {
        if tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {
           tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

}