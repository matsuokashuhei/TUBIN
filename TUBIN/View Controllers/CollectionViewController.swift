//
//  CollectionViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
//import AsyncSwift
import GCDKit
import RealmSwift
import XCGLogger

class CollectionViewController: UIViewController {

    let logger = XCGLogger()

    var collection: Collection!
    var videos = [Video]()

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
        fetch()
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
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StatusBarTouchedNotification, object: nil)
    }

    func configure(navigationItem navigationItem: UINavigationItem) {
        navigationItem.title = collection.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }


}

// MARK: - YouTubeKit
extension CollectionViewController {

    func fetch() {
        Spinner.show()
        let parameters = ["id": collection.videoIds]
        YouTubeKit.videos(parameters: parameters) { (result) -> Void in
            Spinner.dismiss()
            switch result {
            case .Success(let value):
                self.videos = value.videos
                GCDBlock.async(.Main) {
                //Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                Spinner.dismiss()
                Alert.error(error)
            }
        }
    }

}


// MARK: - Realm
extension CollectionViewController {

    func edit() {
        do {
            let realm = try Realm()
            try realm.write {
                if let video = self.videos.first {
                    self.collection.thumbnailURL = video.thumbnailURL
                } else {
                    self.collection.thumbnailURL = ""
                }
                self.collection.videoIds = self.videos.map() { (video) -> String in video.id }.joinWithSeparator(",")
            }
        } catch let error as NSError {
            logger.error(error.description)
        }
    }
}

// MARK: - Table editing
extension CollectionViewController {

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

    func startEditing() {
        setEditing(true, animated: true)
    }

    func endEditing() {
        if edited {
            Spinner.show()
            edit()
            Spinner.dismiss()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CollectionDidChangeNotification, object: self))
        }
        setEditing(false, animated: true)
    }

    func cancelEditing() {
        if edited {
            fetch()
        }
        setEditing(false, animated: true)
    }

}

extension CollectionViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let video = videos[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
        cell.configure(video)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        if tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

}
