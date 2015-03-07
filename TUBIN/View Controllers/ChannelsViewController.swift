//
//  ChannelsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import LlamaKit

class ChannelsViewController: ItemsViewController {

    var category: GuideCategory!

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

    override func configure(#navigationItem: UINavigationItem) {
        super.configure(navigationItem: navigationItem)
        if let category = category {
            navigationItem.title = category.title
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChannel" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as ChannelViewController
                destinationViewController.channel = items[indexPath.row] as Channel
                destinationViewController.navigatable = true
            }
        }
    }

    // MARK: - YouTube search

    override func search() {
        super.search()
        if let category = category {
            YouTubeKit.channels(parameters: parameters) { (result: Result<(page: Page, channels: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchCompletion(page: box.unbox.page, items: box.unbox.channels)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        } else {
            YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchCompletion(page: box.unbox.page, items: box.unbox.items)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        }
    }

    override func searchMore() {
        super.searchMore()
        if let category = category {
            YouTubeKit.channels(parameters: parameters) { (result: Result<(page: Page, channels: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchMoreCompletion(page: box.unbox.page, items: box.unbox.channels)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        } else {
            YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchMoreCompletion(page: box.unbox.page, items: box.unbox.items)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        }
    }

    /*
    override func searchItems(#parameters: [String: String]) {
        super.searchItems(parameters: parameters)
        if let category = category {
            YouTubeKit.channels(parameters: parameters) { (result: Result<(page: Page, channels: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchItemsCompletion(page: box.unbox.page, items: box.unbox.channels)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        } else {
            YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchItemsCompletion(page: box.unbox.page, items: box.unbox.items)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        }
    }
    
    override func loadMoreItems(sender: UIButton) {
        super.loadMoreItems(sender)
        if let category = category {
            YouTubeKit.channels(parameters: parameters) { (result: Result<(page: Page, channels: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.loadMoreItemsCompletion(page: box.unbox.page, items: box.unbox.channels)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        } else {
            YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.loadMoreItemsCompletion(page: box.unbox.page, items: box.unbox.items)
                case .Failure(let box):
                    self.errorCompletion(box.unbox)
                }
            }
        }
    }
    */

}

extension ChannelsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            var cell  = tableView.dequeueReusableCellWithIdentifier("ChannelTableViewCell", forIndexPath: indexPath) as ChannelTableViewCell
            let item = items[indexPath.row] as Channel
            cell.configure(item)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as LoadMoreTableViewCell
            cell.button.addTarget(self, action: "searchMore", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }

}

extension ChannelsViewController: UITableViewDelegate {
}