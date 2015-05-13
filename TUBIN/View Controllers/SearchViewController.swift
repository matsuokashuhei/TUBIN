//
//  SearchViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/04.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import Alamofire
import YouTubeKit
import Async
import XCGLogger

protocol SearchViewControllerDelegate {
    func didChangeItemsViewController(itemsViewController: ItemsViewController) -> Void
}

class SearchViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.searchBarStyle = .Default
        }
    }
    @IBOutlet var suggestionsTableView: UITableView! {
        didSet {
            suggestionsTableView.delegate = self
            suggestionsTableView.dataSource = self
            suggestionsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SuggestionTableViewCell")
        }
    }
    var suggestions = [String]()
    @IBOutlet var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle(NSLocalizedString("Videos", comment: "Videos"), forSegmentAtIndex: 0)
            segmentedControl.setTitle(NSLocalizedString("Playlists", comment: "Playlists"), forSegmentAtIndex: 1)
            segmentedControl.setTitle(NSLocalizedString("Channels", comment: "Channels"), forSegmentAtIndex: 2)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: .ValueChanged)
        }
    }
    @IBOutlet var videosView: UIView!
    @IBOutlet var playlistsView: UIView!
    @IBOutlet var channelsView: UIView!

    var containerViews: [UIView] = []

    var delegate: SearchViewControllerDelegate?

    convenience init() {
        self.init(nibName: "SearchViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let videosViewController = VideosViewController()
        addChildViewController(videosViewController)
//        videosView.addSubview(videosViewController.view)
//        videosViewController.view.frame = videosView.bounds

        let playlistsViewController = PlaylistsViewController()
        addChildViewController(playlistsViewController)
//        playlistsView.addSubview(playlistsViewController.view)
//        playlistsViewController.view.frame = playlistsView.bounds

        let channelsViewController = ChannelsViewController()
        addChildViewController(channelsViewController)
//        channelsView.addSubview(channelsViewController.view)
//        channelsViewController.view.frame = channelsView.bounds

        containerViews = [videosView, playlistsView, channelsView]
        //configure(containerViews: containerViews)
        segmentChanged(segmentedControl)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: HideKeyboardNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Configuration
    func configure(#navigationItem: UINavigationItem) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    // MARK: - Action
    func segmentChanged(sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        let controller = childViewControllers[selectedSegmentIndex] as! ItemsViewController
        for (index, view) in enumerate(containerViews) {
            view.hidden = index != selectedSegmentIndex
            if view.hidden {
                (view.subviews as NSArray).enumerateObjectsUsingBlock { (view, index, stop) in
                    view.removeFromSuperview()
                }
            } else {
                view.addSubview(controller.view)
                controller.view.frame = view.bounds
            }
        }
        if searchBar.text.isEmpty {
            return
        }
        if controller.items.count > 0 && controller.parameters["q"] == searchBar.text {
            return
        }
        search()
    }

    func containerViewAtSelectedSegmentIndex() -> UIView {
        return containerViews[segmentedControl.selectedSegmentIndex]
    }

    func itemViewControllerAtSelectedSegmentIndex() -> ItemsViewController {
        return childViewControllers[segmentedControl.selectedSegmentIndex] as! ItemsViewController
    }

    func search() {
        containerViewAtSelectedSegmentIndex().hidden = false
        suggestionsTableView.hidden = true
        searchBar.resignFirstResponder()
        let itemsViewController = itemViewControllerAtSelectedSegmentIndex()
        itemsViewController.parameters = ["q": searchBar.text]
        itemsViewController.search()
    }

    func hideKeyboard(notification: NSNotification) {
        searchBar.resignFirstResponder()
    }

}

extension SearchViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.text = suggestions[indexPath.row]
        search()
    }

}

extension SearchViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SuggestionTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.font = UIFont(name: Appearance.Font.name, size: 15.0)
        cell.textLabel?.text = suggestions[indexPath.row]
        cell.textLabel?.textColor = Appearance.sharedInstance.theme.textColor
        return cell
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text as NSString).length > 0 {
            YouTubeKit.suggestions(keyword: searchBar.text) { (response) -> Void in
                switch response {
                case .Success(let box):
                    Async.main {
                        self.suggestionsTableView.hidden = false
                        self.containerViewAtSelectedSegmentIndex().hidden = true
                        self.suggestions = box.value
                        self.suggestionsTableView.reloadData()
                    }
                case .Failure(let box):
                    self.logger.error(box.value.localizedDescription)
                    self.containerViewAtSelectedSegmentIndex().hidden = false
                    self.suggestionsTableView.hidden = true
                    break
                }
            }
        } else {
            self.containerViewAtSelectedSegmentIndex().hidden = false
            self.suggestionsTableView.hidden = true
        }
    }
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    }
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    }
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        search()
    }
}
