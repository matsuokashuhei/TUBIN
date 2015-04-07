//
//  HistoriesViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit

class HistoriesViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var tableView: UITableView!

    var histories = [History]()

    convenience override init() {
        self.init(nibName: "HistoriesViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(tableView: tableView)
        fetch()
        setEditing(false)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: "WatchVideoNotification", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
    }

    // MARK: - Parse

    func fetch() {
        History.all { (result) -> Void in
            switch result {
            case .Success(let box):
                Async.background {
                    self.histories = box.unbox
                }.main {
                    self.tableView.reloadData()
                }
            case .Failure(let box):
                let error = box.unbox
                self.logger.error(error.localizedDescription)
                Alert.error(error)
            }
        }
    }

    func setEditing(editing: Bool) {
        tableView.setEditing(editing, animated: true)
        if let toolbar = tableView.tableFooterView as? UIToolbar {
            toolbar.items?.removeAll(keepCapacity: true)
            if tableView.editing {
                toolbar.setItems(
                    [UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing"), UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "endEditing")], animated: true)
            } else {
                toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")], animated: true)
            }
        }
    }

    func startEditing() {
        setEditing(true)
    }

    func endEditing() {
        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            let histories = indexPaths.map() { (indexPath) -> History in
                return self.histories[indexPath.row]
            }
            History.destory(histories, handler: { (result) -> Void in
                switch result {
                case .Success(let box):
                    break
                case .Failure(let box):
                    let error = box.unbox
                    self.logger.error(error.localizedDescription)
                    Alert.error(error)
                }
                self.fetch()
            })
        }
        setEditing(false)
    }

    func cancelEditing() {
        setEditing(false)
    }

}

// MARK: - Table view Delegate
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
        controller.playlist = histories.map { (history) -> Video in
            return history.video
        }
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

// MARK: - Table view data source
extension HistoriesViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as VideoTableViewCell
        var history = histories[indexPath.row]
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

}