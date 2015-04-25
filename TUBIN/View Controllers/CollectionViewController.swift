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

class CollectionViewController: UIViewController {

    let logger = XCGLogger()

    var collection: Collection!
    var videos = [Video]()

//    var parameters = [String: String]()

    var edited = false

    var navigationBarHidden = false

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
//            tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
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
        if let navigationController = navigationController {
            navigationController.navigationBarHidden = navigationBarHidden
        }
    }

    func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = collection.title
    }

    func search() {
        Spinner.show()
//        parameters = ["id": ",".join(collection.videoIds)]
        let parameters = ["id": ",".join(collection.videoIds)]
        YouTubeKit.videos(parameters: parameters) { (result) -> Void in
            Spinner.dismiss()
            switch result {
            case .Success(let box):
                self.videos = box.unbox.videos
//                if let next = box.unbox.page.next {
//                    self.parameters["pageToken"] = next
//                }
                Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let box):
                Spinner.dismiss()
                Alert.error(box.unbox)
            }
        }
    }

//    func searchMore() {
//        YouTubeKit.videos(parameters: parameters) { (result) -> Void in
//            switch result {
//            case .Success(let box):
//                for video in box.unbox.videos {
//                    self.videos.append(video)
//                }
//                if let next = box.unbox.page.next {
//                    self.parameters["pageToken"] = next
//                } else {
//                    self.parameters.removeValueForKey("pageToken")
//                }
//                Async.main {
//                    self.tableView.reloadData()
//                }
//            case .Failure(let box):
//                Alert.error(box.unbox)
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
                    Alert.error(box.unbox)
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