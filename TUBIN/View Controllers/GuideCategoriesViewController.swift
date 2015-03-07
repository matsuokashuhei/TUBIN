//
//  GuideCategoriesViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/01.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import LlamaKit
import SVProgressHUD
import YouTubeKit

class GuideCategoriesViewController: UIViewController {

    // MARK: - YouTube search
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 70
            tableView.tableFooterView = UIView(frame: CGRectZero)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    var categories: [GuideCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        search()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChannels" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let category = categories[indexPath.row]
                let destinationViewController = segue.destinationViewController as ChannelsViewController
                destinationViewController.category = category
                destinationViewController.navigatable = true
                destinationViewController.search(parameters: ["categoryId": category.id])
            }
        }
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
                SVProgressHUD.showErrorWithStatus(box.unbox.localizedDescription)
            }
        }
    }

}

extension GuideCategoriesViewController: UITableViewDelegate {
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