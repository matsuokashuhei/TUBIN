//
//  UserPlaylistsViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import LlamaKit
import XCGLogger
import Async

class CollectionsViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    var collections = [Collection]()

    var edited = false

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
        setEditing(false, animated: true)
        super.viewWillAppear(animated)
    }

}

// MARK: - Parse
extension CollectionsViewController {

    func fetch() {
        Collection.all() { (result: Result<[Collection], NSError>) in
            switch result {
            case .Success(let box):
                self.collections = box.unbox
                Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let box):
                Alert.error(box.unbox)
            }
        }
    }

    func reset(handler: (Result<Bool, NSError>) -> Void) {
        Collection.deleteAll { (result) -> Void in
            switch result {
            case .Success(let box):
                var objects = [PFObject]()
                for (index, collection) in enumerate(self.collections) {
                    let object = collection.toPFObject()
                    object["index"] = index
                    objects.append(object)
                }
                Parser.save(objects) { (result) in
                    handler(result)
                }
                break
            case .Failure(let box):
                break
            }
        }
    }

}

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
        setEditing(true, animated: true)
    }

    func endEditing() {
        if edited {
            Spinner.show()
            reset() { (result) in
                Spinner.dismiss()
                switch result {
                case .Success(let box):
                    self.fetch()
                case .Failure(let box):
                    Alert.error(box.unbox)
                }
            }
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

// MARK: - Table view datasource
extension CollectionsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let collection = collections[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("CollectionTableViewCell", forIndexPath: indexPath) as! CollectionTableViewCell
        cell.configure(collection)
        return cell
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            collections.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            edited = true
        }
    }

    func tableView(tableView: UITableView, accessoryTypeForRowWithIndexPath indexPath: NSIndexPath!) -> UITableViewCellAccessoryType {
        if tableView.editing {
            return .DisclosureIndicator
        } else {
            return .None
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
            let controller = UIAlertController(title: NSLocalizedString("Edit Collection", comment: "Edit Collection"), message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
                let textField = controller.textFields![0] as! UITextField
                collection.title = textField.text
                self.edited = true
                tableView.reloadData()
            }
            OKAction.enabled = false
            controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = NSLocalizedString("Name", comment: "Name")
                textField.text = collection.title
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue
                    .mainQueue()) { (notification) in
                        if textField.text != "" {
                            let collection = Collection(index: self.collections.count, title: textField.text)
                            Collection.count(collection, handler: { (result) -> Void in
                                switch result {
                                case .Success(let box):
                                    OKAction.enabled = box.unbox == 0
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
        } else {
            let controller = CollectionViewController()
            controller.collection = collection
            if let navigationController = navigationController {
                navigationController.pushViewController(controller, animated: true)
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}
