//
//  UserPlaylistsViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import Result
import XCGLogger
//import Parse
import RealmSwift

class CollectionsViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    var collections = [Collection]()

    var edited = false

    var removes = [Collection]()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerNib(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionTableViewCell")
            tableView.allowsSelectionDuringEditing = true
        }
    }

    convenience init() {
        self.init(nibName: "CollectionsViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetch", name: CollectionDidChangeNotification, object: nil)
        fetch()
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTouched:", name: StatusBarTouchedNotification, object: nil)
        setEditing(false, animated: true)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StatusBarTouchedNotification, object: nil)
    }

}

// MARK: - Realm
extension CollectionsViewController {

    func fetch() {
        collections = Collection.all()
        tableView.reloadData()
    }

    func edit() {
        do {
            let realm = try Realm()
            try realm.write {
                for collection in self.removes {
                    realm.delete(collection)
                }
                for (index, collection) in self.collections.enumerate() {
                    collection.index = index
                }
            }
        } catch let error as NSError {
            logger.error(error.description)
        }
    }

}

// MARK: - Table view editing
extension CollectionsViewController {

    override func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
        if let toolbar = tableView.tableFooterView as? UIToolbar {
            toolbar.items?.removeAll(keepCapacity: true)
            if editing {
                let cancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing")
                let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "endEditing")
                toolbar.setItems([cancel, space, done], animated: true)
            } else {
                let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                let edit = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")
                toolbar.setItems([space, edit], animated: true)
            }
        }
        super.setEditing(editing, animated: animated)
        edited = false
    }

    func startEditing() {
        removes = []
        setEditing(true, animated: true)
    }

    func endEditing() {
        if edited {
            Spinner.show()
            edit()
            fetch()
            Spinner.dismiss()
        }
        setEditing(false, animated: true)
    }

    func cancelEditing() {
        if edited {
            fetch()
        }
        setEditing(false, animated: true)
    }

}

// MARK: - Table view data source
extension CollectionsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let collection = collections[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CollectionTableViewCell", forIndexPath: indexPath) as! CollectionTableViewCell
        cell.configure(collection)
        return cell
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .Delete
        }
        return .None
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removes.append(collections.removeAtIndex(indexPath.row))
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            edited = true
        }
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }
        let collection = collections.removeAtIndex(sourceIndexPath.row)
        collections.insert(collection, atIndex: destinationIndexPath.row)
        edited = true
    }
}

// MARK: - Table view delegate
extension CollectionsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let collection = collections[indexPath.row]
        if tableView.editing {
            let controller = UIAlertController(title: NSLocalizedString("Edit collection", comment: "Edit collection"), message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
                let textField = controller.textFields![0] 
                let realm = try! Realm()
                try! realm.write {
                    collection.title = textField.text!
                }
                //self.edited = true
                tableView.reloadData()
                self.setEditing(false, animated: true)
            }
            OKAction.enabled = false
            controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = NSLocalizedString("Name", comment: "Name")
                textField.text = collection.title
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
            return
        }
        if collection.videoCount > 0 {
            let controller = CollectionViewController()
            controller.navigationBarHidden = false
            controller.collection = collection
            if let navigationController = navigationController {
                navigationController.pushViewController(controller, animated: true)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

extension CollectionsViewController {

    func statusBarTouched(notification: NSNotification) {
        if tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

}
