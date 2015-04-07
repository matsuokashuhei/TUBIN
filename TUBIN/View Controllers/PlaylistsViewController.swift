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

    var channel: Channel?

    convenience override init() {
        self.init(nibName: "PlaylistsViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "PlaylistTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaylistTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = PlaylistViewController()
        controller.playlist = items[indexPath.row] as Playlist
        controller.channel = channel
        controller.navigatable = true
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
