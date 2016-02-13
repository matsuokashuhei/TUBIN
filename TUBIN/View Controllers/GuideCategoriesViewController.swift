//
//  GuideCategoriesViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/01.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
//import AsyncSwift
import Alamofire
import GCDKit
import XCGLogger

class GuideCategoriesViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    // MARK: - YouTube search
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerNib(UINib(nibName: "GuideCategoryTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "GuideCategoryTableViewCell")
        }
    }

    var categories: [GuideCategory] = []

    convenience init() {
        self.init(nibName: "GuideCategoriesViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        search()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTouched:", name: StatusBarTouchedNotification, object: nil)

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StatusBarTouchedNotification, object: nil)
    }

    // MARK: - YouTube search

    func search() {
        YouTubeKit.guideCategories() { (result) in
            switch result {
            case .Success(let categories):
                self.categories = categories
                for category in self.categories {
                    YouTubeKit.channels(parameters: ["categoryId": category.id, "maxResults": "1"]) { (result: Result<(page: Page, channels: [Channel]), NSError>) in
                        switch result {
                        case .Success(let value):
                            category.channel = value.channels.first
                        case .Failure(let error):
                            self.logger.error(error.description)
                            break
                        }
                    }
                }
                GCDBlock.async(.Main) {
                //Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                self.logger.error(error.localizedDescription)
                Alert.error(error)
            }
        }
    }

}

extension GuideCategoriesViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category = categories[indexPath.row]
        let controller = ChannelsViewController()
        controller.category = category
        controller.navigatable = true
        controller.parameters = ["categoryId": category.id]
        controller.search()
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

extension GuideCategoriesViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("GuideCategoryTableViewCell", forIndexPath: indexPath) as! GuideCategoryTableViewCell
        cell.configure(categories[indexPath.row])
        return cell
    }
}

extension GuideCategoriesViewController {

    func statusBarTouched(notification: NSNotification) {
        if tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

}