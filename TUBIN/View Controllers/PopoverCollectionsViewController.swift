//
//  PopoverUserPlaylistsViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import Result
import XCGLogger

class PopoverCollectionsViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    var video: Video!
    var collections = [Collection]()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerNib(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionTableViewCell")
        }
    }
    @IBOutlet weak var doneButton: UIBarButtonItem! {
        didSet {
            doneButton.enabled = false
        }
    }

    @IBOutlet weak var item: UINavigationItem! {
        didSet {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonClicked")
            item.rightBarButtonItem = addButton
        }
    }

    convenience init() {
        self.init(nibName: "PopoverCollectionsViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        configure(navigationItem: navigationItem)
        fetch()
        super.viewDidLoad()
    }

    func configure(navigationItem navigationItem: UINavigationItem) {
        edgesForExtendedLayout = .None
        navigationItem.title = NSLocalizedString("Add to favorites", comment: "Add to favorites")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonClicked")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonClicked")
    }

}

// MARK: - Realm
extension PopoverCollectionsViewController {

    func fetch() {
        collections = Collection.all()
        tableView.reloadData()
    }

}

// MARK: - IB actions
extension PopoverCollectionsViewController {

    @IBAction func addButtonClicked() {
        let controller = UIAlertController(title: NSLocalizedString("New collection", comment: "New collection"), message: "", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            let textField = controller.textFields![0] 
            Collection.create(index: self.collections.count, title: textField.text!, videos: [self.video])
            Toast.addToFavorites(video: self.video)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CollectionDidChangeNotification, object: self))
            self.cancelButtonClicked()
        }
        OKAction.enabled = false
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = NSLocalizedString("Name", comment: "Name")
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                if textField.text != "" {
                    OKAction.enabled = Collection.exists(title: textField.text!) == false
                } else {
                    OKAction.enabled = false
                }
            }
        }
        controller.addAction(OKAction)
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel) { (_) in })
        presentViewController(controller, animated: true, completion: nil)
    }

    func cancelButtonClicked() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

// MARK: Table view datasource
extension PopoverCollectionsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let collection = collections[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CollectionTableViewCell", forIndexPath: indexPath) as! CollectionTableViewCell
        cell.configure(collection)
        return cell
    }

}

// MARK: Table view delegate
extension PopoverCollectionsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let collection = collections[indexPath.row]
        if collection.videoCount <= 50 {
            collection.add(video)
            Toast.addToFavorites(video: self.video)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CollectionDidChangeNotification, object: self))
            cancelButtonClicked()
        } else {
            Alert.info(NSLocalizedString("1 Collection, for up to 50 videos", comment: "1 Collection, for up to 50 videos"), autoHide: false)
        }
    }

}