//
//  HistoriesViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import XCGLogger
import RealmSwift

class HistoriesViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        }
    }

    var histories = [History]()

    var edited = false

    convenience init() {
        self.init(nibName: "HistoriesViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setEditing(false, animated: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: "WatchVideoNotification", object: nil)
        fetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - Realm
extension HistoriesViewController {

    func fetch() {
        histories = History.all()
        tableView.reloadData()
    }

}

// MARK: - Table view editing
extension HistoriesViewController {

    override func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
        if let toolbar = tableView.tableFooterView as? UIToolbar {
            toolbar.items?.removeAll(keepCapacity: true)
            if editing {
                let cancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing")
                let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                let trash = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "endEditing")
                toolbar.setItems([cancel, space, trash], animated: true)
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
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        let histories = indexPaths.map() { (indexPath) -> History in
            return self.histories[indexPath.row]
        }
        Spinner.show()
        History.destroy(histories)
        Spinner.dismiss()
        fetch()
        defer {
            setEditing(false, animated: true)
        }
    }

    func cancelEditing() {
        if edited {
            fetch()
        }
        setEditing(false, animated: true)
    }

}

// MARK: - Table view delegate
extension HistoriesViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
        controller.video = histories[indexPath.row].video
        controller.playlist = histories.map { (history) in return history.video }
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

// MARK: - Table view data source
extension HistoriesViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! VideoTableViewCell
        let history = histories[indexPath.row]
        let video = history.video
        cell.configure(video)
        return cell
    }

}

// MARK: - Notification
extension HistoriesViewController {

    func reload(notification: NSNotification) {
        fetch()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTouched:", name: StatusBarTouchedNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StatusBarTouchedNotification, object: nil)
    }

    func statusBarTouched(notification: NSNotification) {
        if tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
    
}
