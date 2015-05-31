//
//  CollectionViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import Async
import XCGLogger
import Box

class CollectionViewController: UIViewController {

    let logger = XCGLogger()

    var collection: Collection!
    var videos = [Video]()

//    var parameters = [String: String]()

    var edited = false

    var navigationBarHidden = true

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        }
    }

    convenience init() {
        self.init(nibName: "CollectionViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(navigationItem: navigationItem)
        setEditing(false, animated: true)
        search()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            navigationController.navigationBarHidden = navigationBarHidden
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTouched:", name: StatusBarTouchedNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StatusBarTouchedNotification, object: nil)
    }

    func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = collection.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        /*
        Bookmark.exists(id: collection.id) { (result) in
            switch result {
            case .Success(let box):
                if box.value {
                    let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromBookmarks")
                    self.navigationItem.rightBarButtonItem = bookmarkButton
                } else {
                    let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addToBookmarks")
                    self.navigationItem.rightBarButtonItem = bookmarkButton
                }
            case .Failure(let box):
                let bookmarkButton = UIBarButtonItem(image: UIImage(named: "ic_bookmark_outline_24px"), style: UIBarButtonItemStyle.Plain, target: self, action: "addToBookmarks")
                self.navigationItem.rightBarButtonItem = bookmarkButton
            }
        }
        */
    }

    func search() {
        Spinner.show()
//        parameters = ["id": ",".join(collection.videoIds)]
        let parameters = ["id": ",".join(collection.videoIds)]
        YouTubeKit.videos(parameters: parameters) { (result) -> Void in
            Spinner.dismiss()
            switch result {
            case .Success(let box):
                self.videos = box.value.videos
//                if let next = box.value.page.next {
//                    self.parameters["pageToken"] = next
//                }
                Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let box):
                Spinner.dismiss()
                Alert.error(box.value)
            }
        }
    }

//    func searchMore() {
//        YouTubeKit.videos(parameters: parameters) { (result) -> Void in
//            switch result {
//            case .Success(let box):
//                for video in box.value.videos {
//                    self.videos.append(video)
//                }
//                if let next = box.value.page.next {
//                    self.parameters["pageToken"] = next
//                } else {
//                    self.parameters.removeValueForKey("pageToken")
//                }
//                Async.main {
//                    self.tableView.reloadData()
//                }
//            case .Failure(let box):
//                Alert.error(box.value)
//            }
//        }
//    }

    override func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
        if let toolbar = tableView.tableFooterView as? UIToolbar {
            toolbar.items?.removeAll(keepCapacity: true)
            if editing {
                let cancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing")
                let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "endEditing")
                toolbar.setItems([cancel, space, done], animated: true)
            } else {
                let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                let edit = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")
                toolbar.setItems([space, edit], animated: true)
            }
        }
        super.setEditing(editing, animated: animated)
        edited = false
    }

}

extension CollectionViewController {

    func addToBookmarks() {
        navigationItem.rightBarButtonItem?.enabled = true
        Bookmark.add(collection) { (result) in
            self.navigationItem.rightBarButtonItem?.enabled = false
            switch result {
            case .Success(let box):
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: AddToBookmarksNotification, object: self, userInfo: ["item": self.collection]))
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
    }

    func removeFromBookmarks() {

    }

}

extension CollectionViewController {

    func startEditing() {
        setEditing(true, animated: true)
    }

    func endEditing() {
        if edited {
            collection.set(videos)
            Collection.save(collection) { (result) in
                switch result {
                case .Success(let box):
                    self.search()
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CollectionDidChangeNotification, object: self))
                case .Failure(let box):
                    Alert.error(box.value)
                }
            }
        }
        setEditing(false, animated: true)
    }

    func cancelEditing() {
        if edited {
            search()
        }
        setEditing(false, animated: true)
    }

}

extension CollectionViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.row < videos.count {
//            let video = videos[indexPath.row]
//            let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
//            cell.configure(video)
//            return cell
//        } else {
//            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as! LoadMoreTableViewCell
//            cell.button.addTarget(self, action: "searchMore", forControlEvents: UIControlEvents.TouchUpInside)
//            return cell
//        }
        let video = videos[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
        cell.configure(video)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView.editing {
//            return videos.count
//        } else {
//            if videos.count > 0 {
//                if let pageToken = parameters["pageToken"] {
//                    return videos.count + 1
//                }
//            }
//            return videos.count
//        }
        return videos.count
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .Delete
        }
        return .None
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            videos.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            edited = true
        }
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }
        let video = videos.removeAtIndex(sourceIndexPath.row)
        videos.insert(video, atIndex: destinationIndexPath.row)
        edited = true
    }

}

extension CollectionViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let video = videos[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
        controller.video = video
        controller.playlist = videos
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

extension CollectionViewController {

    func statusBarTouched(notification: NSNotification) {
        if tableView.numberOfSections() > 0 && tableView.numberOfRowsInSection(0) > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

}
