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
import Box
import Async
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
//            tableView.allowsMultipleSelectionDuringEditing = true
//            tableView.setEditing(true, animated: true)
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

    func configure(#navigationItem: UINavigationItem) {
        edgesForExtendedLayout = .None
        navigationItem.title = NSLocalizedString("Add to favorites", comment: "Add to favorites")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonClicked")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonClicked")
    }

}

// MARK: - Parse
extension PopoverCollectionsViewController {

    func fetch() {
        Collection.all() { (result: Result<[Collection], NSError>) in
            switch result {
            case .Success(let box):
                self.collections = box.value
                Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let box):
                Alert.error(box.value)
            }
        }
    }

    func add(collection: Collection, video: Video, handler: (Result<Bool, NSError>) -> Void) {
        collection.add(video)
        Collection.save(collection) { (result) in
            handler(result)
        }
    }
}

// MARK: - IB actions
extension PopoverCollectionsViewController {

    @IBAction func addButtonClicked() {
        let controller = UIAlertController(title: NSLocalizedString("New collection", comment: "New collection"), message: "", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            let textField = controller.textFields![0] as! UITextField
            let collection = Collection(index: self.collections.count, title: textField.text)
            collection.add(self.video)
            Collection.create(collection) { (result) in
                switch result {
                case .Success(let box):
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CollectionDidChangeNotification, object: self))
                    self.cancelButtonClicked()
                case .Failure(let box):
                    Alert.error(box.value)
                }
            }
        }
        OKAction.enabled = false
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = NSLocalizedString("Name", comment: "Name")
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue
                .mainQueue()) { (notification) in
                    if textField.text != "" {
                        let collection = Collection(index: self.collections.count, title: textField.text)
                        Collection.count(collection, handler: { (result) -> Void in
                            switch result {
                            case .Success(let box):
                                OKAction.enabled = box.value == 0
                            case .Failure(let box):
                                OKAction.enabled = false
                            }
                        })
                    } else {
                        OKAction.enabled = false
                    }
            }
        }
        controller.addAction(OKAction)
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (_) in })
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
        var cell = tableView.dequeueReusableCellWithIdentifier("CollectionTableViewCell", forIndexPath: indexPath) as! CollectionTableViewCell
        cell.configure(collection)
        return cell
    }

}

// MARK: Table view delegate
extension PopoverCollectionsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let collection = collections[indexPath.row]
        if collection.videoIds.count <= 50 {
            add(collection, video: video) { (result) in
                switch result {
                case .Success(let box):
                    Toast.addToFavorites(video: self.video)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: CollectionDidChangeNotification, object: self))
                    self.cancelButtonClicked()
                case .Failure(let box):
                    Alert.error(box.value)
                }
            }
        } else {
            Alert.info(NSLocalizedString("1 Collection, for up to 50 videos", comment: "1 Collection, for up to 50 videos"), autoHide: false)
        }
    }

}