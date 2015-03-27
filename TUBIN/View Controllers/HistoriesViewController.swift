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

    @IBOutlet weak var tableView: UITableView!

    var histories = [History]()

    convenience override init() {
        self.init(nibName: "HistoriesViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(tableView: tableView)
        fetch()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: "WatchVideoNotification", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configure(#tableView: UITableView) {
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
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
                Alert.error(box.unbox)
            }
        }
    }

}

// MARK: - Table view Delegate
extension HistoriesViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
        controller.video = histories[indexPath.row].video
        controller.playlist = histories.map { (history) -> Video in
            return history.video
        }
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
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