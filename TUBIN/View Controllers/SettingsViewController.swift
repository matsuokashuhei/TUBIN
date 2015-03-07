//
//  SettingsViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/17.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBookmarks" {
            let destinationViewController = segue.destinationViewController as BookmarksViewController
        }
    }

    @IBAction func showFLEX(sender: UISwitch) {
        if sender.on {
//            FLEXManager.sharedManager().showExplorer()
        }
    }

    @IBAction func showAdBanner(sender: UISwitch) {
        NSNotificationCenter.defaultCenter().postNotificationName(BannerShowableNotification, object: self, userInfo: ["showable": sender.on])
    }

}

extension SettingsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Edit"
        default:
            return "Develop"
        }
    }

}

extension SettingsViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("EditTableViewCell", forIndexPath: indexPath) as UITableViewCell
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                var cell = tableView.dequeueReusableCellWithIdentifier("DebugTableViewCell", forIndexPath: indexPath) as UITableViewCell
                return cell
            case 1:
                var cell = tableView.dequeueReusableCellWithIdentifier("iAdTableViewCell", forIndexPath: indexPath) as UITableViewCell
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }

}
