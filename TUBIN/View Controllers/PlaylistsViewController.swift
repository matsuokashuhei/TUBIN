//
//  PlaylistsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import LlamaKit

class PlaylistsViewController: ItemsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPlaylist" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as PlaylistViewController
                destinationViewController.playlist = items[indexPath.row] as Playlist
                destinationViewController.navigatable = true
            }
        }
    }

    // MARK: - YouTube search
    override func search() {
        super.search()
        YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Playlist]), NSError>) -> Void in
            switch result {
            case .Success(let box):
                self.searchCompletion(page: box.unbox.page, items: box.unbox.items)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }

    override func searchMore() {
        super.searchMore()
        YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Playlist]), NSError>) -> Void in
            switch result {
            case .Success(let box):
                self.searchMoreCompletion(page: box.unbox.page, items: box.unbox.items)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }
    /*
    override func searchItems(#parameters: [String: String]) {
        super.searchItems(parameters: parameters)
        YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Playlist]), NSError>) -> Void in
            switch result {
            case .Success(let box):
                self.searchItemsCompletion(page: box.unbox.page, items: box.unbox.items)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }

    override func loadMoreItems(sender: UIButton) {
        super.loadMoreItems(sender)
        YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Playlist]), NSError>) -> Void in
            switch result {
            case .Success(let box):
                self.loadMoreItemsCompletion(page: box.unbox.page, items: box.unbox.items)
            case .Failure(let box):
                self.errorCompletion(box.unbox)
            }
        }
    }
    */

}

extension PlaylistsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            var cell  = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell", forIndexPath: indexPath) as PlaylistTableViewCell
            let item = items[indexPath.row] as Playlist
            cell.configure(item)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as LoadMoreTableViewCell
            cell.button.addTarget(self, action: "searchMore", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }
    
}

extension PlaylistsViewController: UITableViewDelegate {
}