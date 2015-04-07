//
//  FavoritesViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/19.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import LlamaKit

class FavoritesViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var tableView: UITableView!

    var favorites = [Favorite]()

    var edited = false

    var removes = [Favorite]()

    convenience override init() {
        self.init(nibName: "FavoritesViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(tableView: tableView)
        fetch()
        setEditing(false)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: AddItemToFavoritesNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: ReloadFavoritesNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
    }

    // MARK: - Parse

    func fetch() {
        Favorite.all { (result) -> Void in
            switch result {
            case .Success(let box):
                Async.background {
                    self.favorites = box.unbox
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

    // MARK: - IBActions

    func setEditing(editing: Bool) {
        tableView.setEditing(editing, animated: true)
        if let toolbar = tableView.tableFooterView as? UIToolbar {
            toolbar.items?.removeAll(keepCapacity: true)
            if tableView.editing {
                toolbar.setItems(
                    [UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing"), UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "endEditing")], animated: true)
            } else {
                toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")], animated: true)
            }
        }
    }

    func startEditing() {
        setEditing(true)
        edited = false
        removes = []
    }

    func endEditing() {
        if edited {
            Spinner.show()
            let results = Favorite.edit(updates: favorites, removes: removes)
            switch results {
            case .Success(let box):
                Spinner.dismiss()
            case .Failure(let box):
                let error = box.unbox
                self.logger.error(error.localizedDescription)
                Alert.error(error)
            }
        }
        setEditing(false)
    }

    func cancelEditing() {
        if edited {
            fetch()
        }
        setEditing(false)
    }

}

// MARK: - Table view Delegate
extension FavoritesViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }
        edited = true
        let favorite = favorites.removeAtIndex(sourceIndexPath.row)
        favorites.insert(favorite, atIndex: destinationIndexPath.row)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removes.append(favorites.removeAtIndex(indexPath.row))
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            edited = true
        }
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .Delete
        }
        return .None
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        let controller = YouTubePlayerViewController(device: UIDevice.currentDevice())
        controller.video = favorites[indexPath.row].video
        controller.playlist = favorites.map { (favorite) -> Video in
            return favorite.video
        }
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - Table view data source
extension FavoritesViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as VideoTableViewCell
        var favorite = favorites[indexPath.row]
        let video = favorite.video
        cell.configure(video)
        return cell
    }

}

// MARK: - Notification
extension FavoritesViewController {

    func reload(notification: NSNotification) {
        if let item = notification.userInfo?["item"] as? Item {
            Toast.show(item: item)
        }
        fetch()
    }

}