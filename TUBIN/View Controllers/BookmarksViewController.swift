//
//  BookmarksViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import Result
import Async
import XCGLogger
import RealmSwift

class BookmarksViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: CGRectZero)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerNib(UINib(nibName: "BookmarkTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "BookmarkTableViewCell")
        }
    }

    var bookmarks = [Bookmark]()
    var removes = [Bookmark]()
    var edited = false

    convenience init() {
        self.init(nibName: "BookmarksViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure(navigationItem: navigationItem)
        fetch()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setEditing(false, animated: true)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = NSLocalizedString("Bookmarks", comment: "Bookmarks")
    }

}

// MARK: - Realm
extension BookmarksViewController {

    func fetch() {
        Spinner.show()
        bookmarks = Bookmark.all()
        tableView.reloadData()
        Spinner.dismiss()
    }

    func edit() {
        Spinner.show()
        let realm = Realm()
        realm.write {
            for bookmark in self.removes {
                realm.delete(bookmark)
            }
            for (index, bookmark) in enumerate(self.bookmarks) {
                bookmark.index = index + 1
            }
        }
        Spinner.dismiss()
    }

}

// MARK: - Table view editing
extension BookmarksViewController {

    override func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: true)
        navigationItem.rightBarButtonItem = {
            if self.tableView.editing {
                return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "endEditing")
            } else {
                return UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")
            }
        }()
        super.setEditing(editing, animated: animated)
        edited = false
    }

    func startEditing() {
        removes = []
        setEditing(true, animated: true)
    }

    func endEditing() {
        if edited {
            edit()
            fetch()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BookmarksEditedNotification, object: self))
        }
        setEditing(false, animated: true)
    }

}

// MARK: - Table view dalegate
extension BookmarksViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            let bookmark = bookmarks[indexPath.row]
            if bookmark.editable {
                return .Delete
            }
        }
        return .None
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return
        }
        let bookmark = bookmarks.removeAtIndex(sourceIndexPath.row)
        bookmarks.insert(bookmark, atIndex: destinationIndexPath.row)
        edited = true
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removes.append(bookmarks.removeAtIndex(indexPath.row))
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            edited = true
        }
    }
}

// MARK: - Table view data source
extension BookmarksViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let bookmark = bookmarks[indexPath.row]
        var cell  = tableView.dequeueReusableCellWithIdentifier("BookmarkTableViewCell", forIndexPath: indexPath) as! BookmarkTableViewCell
        cell.configure(bookmark)
        if bookmark.preseted {
            cell.thumbnailImageView.alpha = 0.5
            cell.thumbnailImageView.backgroundColor = Appearance.sharedInstance.theme.textColor.colorWithAlphaComponent(0.1)
        } else {
            cell.thumbnailImageView.alpha = 1.0
            cell.thumbnailImageView.backgroundColor = UIColor.clearColor()
        }
        return cell
    }

}