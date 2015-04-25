//
//  UserViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import XCGLogger

class UserViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var segmentedControl: UISegmentedControl! {
        didSet {
            //segmentedControl.setTitle(NSLocalizedString("Favorites", comment: "Favorites"), forSegmentAtIndex: 0)
            segmentedControl.setTitle(NSLocalizedString("Collection", comment: "Collection"), forSegmentAtIndex: 0)
            segmentedControl.setTitle(NSLocalizedString("Recents", comment: "Recents"), forSegmentAtIndex: 1)
        }
    }

    @IBOutlet var favoritesView: UIView!
    @IBOutlet var historiesView: UIView!

    var containerViews: [UIView] = []

    convenience init() {
        self.init(nibName: "UserViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        /*
        let favoritesViewController = FavoritesViewController()
        addChildViewController(favoritesViewController)
        favoritesView.addSubview(favoritesViewController.view)
        favoritesViewController.view.frame = favoritesView.bounds
        */

        configure(collectionsView: favoritesView)
        configure(recentsView: historiesView)
        containerViews = [favoritesView, historiesView]

        configure(segmentedControl)
        segmentChanged(segmentedControl)
    }

    func configure(segmentedControl: UISegmentedControl) {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: .ValueChanged)
    }

    func segmentChanged(sender: UISegmentedControl) {
        for view in containerViews {
            view.hidden = true
        }
        containerViews[sender.selectedSegmentIndex].hidden = false
    }

    func configure(collectionsView view: UIView) {
        let controller = CollectionsViewController()
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
    }

    func configure(recentsView view: UIView) {
        let controller = HistoriesViewController()
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
