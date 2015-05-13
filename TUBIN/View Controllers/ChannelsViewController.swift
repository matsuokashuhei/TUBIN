//
//  ChannelsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import Result

class ChannelsViewController: ItemsViewController {

    var category: GuideCategory!

    convenience init() {
        self.init(nibName: "ChannelsViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "ChannelTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ChannelTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "LoadMoreTableViewCell")
    }

    override func configure(#navigationItem: UINavigationItem) {
        super.configure(navigationItem: navigationItem)
        edgesForExtendedLayout = .None
        if let category = category {
            navigationItem.title = category.title
        }
    }

    // MARK: - YouTube search

    override func search() {
        super.search()
        if let category = category {
            YouTubeKit.channels(parameters: parameters) { (result: Result<(page: Page, channels: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchCompletion(page: box.value.page, items: box.value.channels)
                case .Failure(let box):
                    self.errorCompletion(box.value)
                }
            }
        } else {
            YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchCompletion(page: box.value.page, items: box.value.items)
                case .Failure(let box):
                    self.errorCompletion(box.value)
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
                    self.searchMoreCompletion(page: box.value.page, items: box.value.channels)
                case .Failure(let box):
                    self.errorCompletion(box.value)
                }
            }
        } else {
            YouTubeKit.search(parameters: parameters) { (result: Result<(page: Page, items: [Channel]), NSError>) -> Void in
                switch result {
                case .Success(let box):
                    self.searchMoreCompletion(page: box.value.page, items: box.value.items)
                case .Failure(let box):
                    self.errorCompletion(box.value)
                }
            }
        }
    }

}

extension ChannelsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            let item = items[indexPath.row] as! Channel
            var cell  = tableView.dequeueReusableCellWithIdentifier("ChannelTableViewCell", forIndexPath: indexPath) as! ChannelTableViewCell
            cell.configure(item)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as! LoadMoreTableViewCell
            cell.button.addTarget(self, action: "searchMore", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }

}

extension ChannelsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = ChannelViewController()
        controller.channel = items[indexPath.row] as! Channel
        controller.navigatable = true
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}