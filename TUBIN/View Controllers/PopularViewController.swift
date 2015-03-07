//
//  PopularsViewController.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

class PopularViewController: UIViewController {

    @IBOutlet var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    @IBOutlet var playlistsView: UIView!
    @IBOutlet var channelsView: UIView!

    var containerViews: [UIView] = []

    var parameters = ["order": "viewCount"]

    override func viewDidLoad() {
        super.viewDidLoad()

        containerViews = [playlistsView, channelsView]
        containerViews.last!.hidden = true

        if let playlistsViewController = childViewControllers[0] as? PlaylistsViewController {
            playlistsViewController.search(parameters: parameters)
        }
        if let channelsViewController = childViewControllers[1] as? ChannelsViewController {
            channelsViewController.search(parameters: parameters)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func segmentChanged(sender: UISegmentedControl) {
        for view in containerViews {
            view.hidden = true
        }
        containerViews[sender.selectedSegmentIndex].hidden = false
    }

}
