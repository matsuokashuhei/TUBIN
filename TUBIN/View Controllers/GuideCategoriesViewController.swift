//
//  GuideCategoriesViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/01.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import LlamaKit
import YouTubeKit

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

    convenience override init() {
        self.init(nibName: "GuideCategoriesViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        search()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - YouTube search

    func search() {
        YouTubeKit.guideCategories() { (result) in
            switch result {
            case .Success(let box):
                Async.background {
                    self.categories = box.unbox
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

}

extension GuideCategoriesViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category = categories[indexPath.row]
        let controller = ChannelsViewController()
        controller.category = category
        controller.navigatable = true
        controller.search(parameters: ["categoryId": category.id])
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.alpha = 0
        UIView.animateWithDuration(0.5, animations: { cell.alpha = 1 })
    }

}

extension GuideCategoriesViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell  = tableView.dequeueReusableCellWithIdentifier("GuideCategoryTableViewCell", forIndexPath: indexPath) as GuideCategoryTableViewCell
        cell.configure(categories[indexPath.row])
        return cell
    }
}