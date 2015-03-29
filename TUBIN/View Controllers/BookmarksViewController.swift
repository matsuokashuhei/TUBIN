//
//  BookmarksViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import LlamaKit

class BookmarksViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var tableView: UITableView!

    var bookmarks = [Bookmark]()
    var edited = false

    convenience override init() {
        self.init(nibName: "BookmarksViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(navigationItem: navigationItem)
        configure(tableView: tableView)

        Bookmark.all { (result: Result<[Bookmark], NSError>) -> Void in
            switch result {
            case .Success(let box):
                Async.background {
                    self.bookmarks = box.unbox
                }.main {
                    self.tableView.reloadData()
                }
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
            }
        }

        if let navigationController = self.navigationController {
            configure(navigationItem: navigationItem)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        tableView.setEditing(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = "Bookmark"
        setEditing(false)
    }

    func configure(#tableView: UITableView) {
        //tableView.rowHeight = 76
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "BookmarkTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "BookmarkTableViewCell")
    }

    func setEditing(editing: Bool) {
        tableView.setEditing(editing, animated: true)
        if tableView.editing {
            let button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "endEditing")
            navigationItem.rightBarButtonItem = button
        } else {
            let button = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")
            navigationItem.rightBarButtonItem = button
        }
    }

    // MARK: - Actions

    func startEditing() {
        edited = false
        setEditing(true)
    }

    func endEditing() {
        setEditing(false)
        if edited {
            Bookmark.reset(bookmarks) { (result) in
                switch result {
                case .Success(let box):
                    Async.main {
                        self.tableView.reloadData()
                    }
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BookmarksEditedNotification, object: self))
                case .Failure(let box):
                    let error = box.unbox
                    self.logger.error(error.localizedDescription)
                    Alert.error(error)
                }
            }
            edited = false
        }
    }

}

extension BookmarksViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let bookmark = bookmarks[indexPath.row]
        if bookmark.name == "playlist" || bookmark.name == "channel" {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
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
            let bookmark = bookmarks.removeAtIndex(indexPath.row)
            edited = true
            tableView.reloadData()
        }
    }
}

extension BookmarksViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell  = tableView.dequeueReusableCellWithIdentifier("BookmarkTableViewCell", forIndexPath: indexPath) as BookmarkTableViewCell
        cell.configure(bookmarks[indexPath.row])
        return cell
    }
}