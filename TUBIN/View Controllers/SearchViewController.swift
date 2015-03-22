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

protocol SearchViewControllerDelegate {
    func didChangeItemsViewController(itemsViewController: ItemsViewController) -> Void
}

class SearchViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
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
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: .ValueChanged)
        }
    }
    @IBOutlet var videosView: UIView!
    @IBOutlet var playlistsView: UIView!
    @IBOutlet var channelsView: UIView!

    var containerViews: [UIView] = []

    var delegate: SearchViewControllerDelegate?

    convenience override init() {
        self.init(nibName: "SearchViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let videosViewController = VideosViewController()
        addChildViewController(videosViewController)
        videosView.addSubview(videosViewController.view)
        videosViewController.view.frame = videosView.bounds

        let playlistsViewController = PlaylistsViewController()
        addChildViewController(playlistsViewController)
        playlistsView.addSubview(playlistsViewController.view)
        playlistsViewController.view.frame = playlistsView.bounds

        let channelsViewController = ChannelsViewController()
        addChildViewController(channelsViewController)
        channelsView.addSubview(channelsViewController.view)
        channelsViewController.view.frame = channelsView.bounds

        containerViews = [videosView, playlistsView, channelsView]
        configure(containerViews: containerViews)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Configuration
    func configure(#navigationItem: UINavigationItem) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    func configure(#containerViews: [UIView]) {
        for view in containerViews {
            view.hidden = true
        }
        containerViewAtSelectedSegmentIndex().hidden = false
    }

    // MARK: - Action
    func segmentChanged(sender: UISegmentedControl) {
        configure(containerViews: containerViews)

        let itemsViewController = itemViewControllerAtSelectedSegmentIndex()
        if itemsViewController.items.count > 0 && itemsViewController.parameters["q"] == searchBar.text {
            return
        }
        search()
        //searchBar.delegate = itemViewControllerAtSelectedSegmentIndex()
        //searchBar.delegate!.searchBarSearchButtonClicked!(searchBar)
        //delegate?.didChangeItemsViewController(itemViewControllerAtSelectedSegmentIndex())
    }

    func containerViewAtSelectedSegmentIndex() -> UIView {
        return containerViews[segmentedControl.selectedSegmentIndex]
    }

    func itemViewControllerAtSelectedSegmentIndex() -> ItemsViewController {
        return childViewControllers[segmentedControl.selectedSegmentIndex] as ItemsViewController
    }


    func search() {
        containerViewAtSelectedSegmentIndex().hidden = false
        suggestionsTableView.hidden = true
        searchBar.resignFirstResponder()
        let itemsViewController = itemViewControllerAtSelectedSegmentIndex()
        itemsViewController.parameters = ["q": searchBar.text]
        itemsViewController.search()
        //itemsViewController.searchItems(parameters: ["q": searchBar.text])
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
        logger.debug("")
        return suggestions.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        logger.debug("")
        var cell = tableView.dequeueReusableCellWithIdentifier("SuggestionTableViewCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15.0)
        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        logger.debug("searchText: \(searchText)")
        if (searchBar.text as NSString).length > 0 {
            YouTubeKit.suggestions(keyword: searchBar.text) { (response) -> Void in
                switch response {
                case .Success(let box):
                    Async.main {
                        self.suggestionsTableView.hidden = false
                        self.containerViewAtSelectedSegmentIndex().hidden = true
                        self.suggestions = box.unbox
                        self.suggestionsTableView.reloadData()
                    }
                case .Failure(let box):
                    self.logger.error(box.unbox.localizedDescription)
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
        logger.debug("searchBar.text: \(searchBar.text)")
        return true
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        logger.debug("searchBar.text: \(searchBar.text)")
    }
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        logger.debug("searchBar.text: \(searchBar.text)")
        return true
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        logger.debug("searchBar.text: \(searchBar.text)")
    }
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        logger.debug("searchBar.text: \(searchBar.text), range: \(range), text: \(text)")
        return true
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        logger.debug("searchBar.text: \(searchBar.text)")
        search()
    }
}
