//
//  SettingsViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/17.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import Social
import SwiftyUserDefaults

class SettingsViewController: UIViewController {

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.registerNib(UINib(nibName: "DarkModeTableViewCell", bundle: nil), forCellReuseIdentifier: "DarkModeTableViewCell")
        }
    }

    convenience init() {
        self.init(nibName: "SettingsViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
    }

    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SettingsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return ""
        default:
            return ""
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if let navigationController = navigationController {
                    navigationController.pushViewController(BookmarksViewController(), animated: true)
                }
            default:
                break
            }
        case 1:
            if let navigationController = navigationController {
                if let upgraded = Defaults["upgraded"].bool {
                    if !upgraded {
                        navigationController.pushViewController(StoreViewController(), animated: true)
                    }
                } else {
                    navigationController.pushViewController(StoreViewController(), animated: true)
                }
            }
        case 2:
            switch indexPath.row {
            case 0:
                let text = NSLocalizedString("Best YouTube App for iPhone & iPad !", comment: "Best YouTube App for iPhone & iPad !")
                let URL = NSURL(string: "http://itunes.apple.com/app/id978972681?mt=8")
                let shareMenu = UIAlertController(title: nil, message: NSLocalizedString("Share using", comment: "Share using"), preferredStyle: .ActionSheet)
                for SNS in [(name: "Twitter", type: SLServiceTypeTwitter), (name: "Facebook", type: SLServiceTypeFacebook)] {
                    let action = UIAlertAction(title: SNS.name, style: .Default) { (action) in
                        if SLComposeViewController.isAvailableForServiceType(SNS.type) {
                            let controller = SLComposeViewController(forServiceType: SNS.type)
                            controller.setInitialText(text)
                            controller.addURL(URL)
                            self.presentViewController(controller, animated: true, completion: nil)
                        } else {
                            let localizedString = NSLocalizedString("You haven't registered your %@ account. Please go to Settings > %@ to create one.", comment: "SNS")
                            let message = String(format: localizedString, SNS.name, SNS.name)
                            Alert.info(message, autoHide: false)
                        }
                    }
                    shareMenu.addAction(action)
                }
                shareMenu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                presentViewController(shareMenu, animated: true, completion: nil)
            case 1:
                let URL = "itms-apps://itunes.apple.com/app/id978972681"
                UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

extension SettingsViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1
        case 2: return 2
        default: return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DarkModeTableViewCell", forIndexPath: indexPath) as! DarkModeTableViewCell
            cell.titleLabel.font = UIFont(name: Appearance.Font.name, size: 15.0)!
            cell.titleLabel.textColor = Appearance.sharedInstance.theme.textColor
            cell.titleLabel.text = NSLocalizedString("Dark mode", comment: "Dark mode")
            if Defaults["theme"].string == "Light" {
                cell.darkModeSwitch.on = false
            } else {
                cell.darkModeSwitch.on = true
            }
            cell.darkModeSwitch.addTarget(self, action: "darkModeSwitchChanged:", forControlEvents: .ValueChanged)
            return cell
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("SettingTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = {
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    return NSLocalizedString("Edit bookmarks", comment: "Edit bookmarks")
                case 1:
                    return NSLocalizedString("Dark mode", comment: "Dark mode")
                default:
                    return ""
                }
            case 1:
                return NSLocalizedString("Ad-free on iOS", comment: "Ad-free on iOS")
            case 2:
                switch indexPath.row {
                case 0:
                    return NSLocalizedString("Share this app", comment: "Share this app")
                case 1:
                    return NSLocalizedString("Rate this app", comment: "Rate this app")
                default:
                    return ""
                }
            default:
                return ""
            }
        }()
        cell.textLabel?.font = UIFont(name: Appearance.Font.name, size: 15.0)!
        cell.textLabel?.textColor = Appearance.sharedInstance.theme.textColor
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.accessoryType = {
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    return .DisclosureIndicator
                default:
                    return .None
                }
            case 1:
                if let upgraded = Defaults["upgraded"].bool {
                    if upgraded {
                        return .None
                    }
                }
                return .DisclosureIndicator
            case 2:
                return .DisclosureIndicator
            default:
                return .None
            }
        }()
        return cell
    }

    func darkModeSwitchChanged(sender: UISwitch) {
        if sender.on {
            Defaults["theme"] = "Dark"
            Appearance.sharedInstance.apply(.Dark)
        } else {
            Defaults["theme"] = "Light"
            Appearance.sharedInstance.apply(.Light)
        }
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: SwitchThemeNotification, object: self))
    }
}
