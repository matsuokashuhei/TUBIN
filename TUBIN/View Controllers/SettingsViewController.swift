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

    convenience override init() {
        self.init(nibName: "SettingsViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "EditTableViewCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "StoreTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SettingsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Edit"
        case 1:
            return ""
        default:
            return "Develop"
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let controller = BookmarksViewController()
            if let navigationController = navigationController {
                navigationController.pushViewController(controller, animated: true)
            }
        case 1:
            let controller = StoreViewController()
            if let navigationController = navigationController {
                navigationController.pushViewController(controller, animated: true)
            }
        default:
            break
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
            return 1
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("EditTableViewCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = NSLocalizedString("Subscriptions", comment: "Subscriptions")
            cell.textLabel?.font = UIFont(name: Appearance.Font.name, size: 15.0)!
            return cell
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("StoreTableViewCell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = NSLocalizedString("Store", comment: "Store")
            cell.textLabel?.font = UIFont(name: Appearance.Font.name, size: 15.0)!
            return cell
        default:
            return UITableViewCell()
        }
    }

}
