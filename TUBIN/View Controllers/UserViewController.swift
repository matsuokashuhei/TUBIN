//
//  UserViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBOutlet var favoritesView: UIView!
    @IBOutlet var historiesView: UIView!

    var containerViews: [UIView] = []

    convenience override init() {
        self.init(nibName: "UserViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        let favoritesViewController = FavoritesViewController()
        addChildViewController(favoritesViewController)
        favoritesView.addSubview(favoritesViewController.view)
        favoritesViewController.view.frame = favoritesView.bounds

        let historiesViewController = HistoriesViewController()
        addChildViewController(historiesViewController)
        historiesView.addSubview(historiesViewController.view)
        historiesViewController.view.frame = historiesView.bounds

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
