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
            segmentedControl.setTitle(NSLocalizedString("Videos", comment: "Videos"), forSegmentAtIndex: 0)
            segmentedControl.setTitle(NSLocalizedString("Playlists", comment: "Playlists"), forSegmentAtIndex: 1)
            segmentedControl.setTitle(NSLocalizedString("Channels", comment: "Channels"), forSegmentAtIndex: 2)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    @IBOutlet weak var videosView: UIView!
    @IBOutlet weak var playlistsView: UIView!
    @IBOutlet weak var channelsView: UIView!

    var containerViews: [UIView] = []

    convenience init() {
        self.init(nibName: "PopularViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(videosView: videosView)
        configure(playlistsView: playlistsView)
        configure(channelsView: channelsView)

        containerViews = [videosView, playlistsView, channelsView]

        segmentChanged(segmentedControl)
    }

    func configure(videosView view: UIView) {
        let controller = VideosViewController()
        controller.parameters = ["chart": "mostPopular"]
        addChildViewController(controller)
//        view.addSubview(controller.view)
//        controller.view.frame = view.bounds
    }

    func configure(playlistsView view: UIView) {
        let controller = PlaylistsViewController()
        let aWeekAgo = NSDate().dateByAddingDays(-30).toString(format: .Custom("yyyy-MM-dd'T'HH:mm:ss'Z'"))
        controller.parameters = ["order": "viewCount", "publishedAfter": aWeekAgo]
        //controller.search()
        addChildViewController(controller)
//        view.addSubview(controller.view)
//        controller.view.frame = view.bounds
//        view.hidden = true
    }

    func configure(channelsView view: UIView) {
        let controller = ChannelsViewController()
        let aWeekAgo = NSDate().dateByAddingDays(-30).toString(format: .Custom("yyyy-MM-dd'T'HH:mm:ss'Z'"))
        controller.parameters = ["order": "viewCount", "publishedAfter": aWeekAgo]
        //controller.search()
        addChildViewController(controller)
//        view.addSubview(controller.view)
//        controller.view.frame = view.bounds
//        view.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func segmentChanged(sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        if let controller = childViewControllers[selectedSegmentIndex] as? ItemsViewController {
            for (index, view) in containerViews.enumerate() {
                view.hidden = index != selectedSegmentIndex
                if view.hidden {
                    (view.subviews as NSArray).enumerateObjectsUsingBlock { (view, index, stop) in
                        view.removeFromSuperview()
                    }
                } else {
                    view.addSubview(controller.view)
                    controller.view.frame = view.bounds
                    if controller.items.count == 0 {
                        controller.search()
                    }
                }
            }
        }
    }

}
