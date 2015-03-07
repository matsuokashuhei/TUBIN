//
//  GuideCategoriesTableViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/07.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import LlamaKit
import SVProgressHUD
import YouTubeKit

class GuideCategoriesTableViewController: UITableViewController {

    var categories: [GuideCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.setNavigationBarHidden(true, animated: true)
        configuire(tableView)
        search()
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configuire(tableView: UITableView) {
        let nib = UINib(nibName: "GuideCategoryTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "GuideCategoryTableViewCell")
    }

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

// MARK: - Table view data source
extension GuideCategoriesTableViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return categories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell  = tableView.dequeueReusableCellWithIdentifier("GuideCategoryTableViewCell", forIndexPath: indexPath) as GuideCategoryTableViewCell
        cell.configure(categories[indexPath.row])
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Table view delegate
extension GuideCategoriesTableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category = categories[indexPath.row]
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let controller = storyboard.instantiateViewControllerWithIdentifier("ChannelsViewController") as ChannelsViewController
        */
        let controller = ChannelsViewController(nibName: "ChannelsViewController", bundle: NSBundle.mainBundle())
        controller.category = category
        controller.navigatable = true
        controller.search(parameters: ["categoryId": category.id])
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
    }

}
