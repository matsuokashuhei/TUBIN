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
import SVProgressHUD

class FavoritesViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var tableView: UITableView!

    @IBOutlet var editButton: UIBarButtonItem!

    var favorites = [Favorite]()

    var edited = false

    var removes = [Favorite]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(tableView: tableView)
        fetch()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:", name: AddItemToFavoritesNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#tableView: UITableView) {
        tableView.rowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRectZero)
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
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
    }

    // MARK: - IBActions

    @IBAction func editButtonTapped() {
        logger.debug("called")
        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing {
            editButton.title = "Done"
            edited = false
            removes = []
        } else {
            editButton.title = "Edit"
            if edited {
                Spinner.show()
                let results = Favorite.edit(updates: favorites, removes: removes)
                switch results {
                case .Success(let box):
                    Spinner.dismiss()
                case .Failure(let box):
                    logger.error(box.unbox.localizedDescription)
                    SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
                }
            }
        }
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
            logger.debug("indexPath: \(indexPath)")
            removes.append(favorites.removeAtIndex(indexPath.row))
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            edited = true
        }
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(HideMiniPlayerNotification, object: self)
        let player = YouTubePlayer.sharedInstance
        //player.setPlaylist(items as [Video], index: indexPath.row)
        player.nowPlaying = favorites[indexPath.row].video
        let controller = YouTubePlayerViewController(nibName: "YouTubePlayerViewController", bundle: NSBundle.mainBundle())
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
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
            Toast.favorite(item: item)
        }
        fetch()
    }

}