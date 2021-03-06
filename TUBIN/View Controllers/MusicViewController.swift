//
//  MusicViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/05/14.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
//import AsyncSwift
import GCDKit
import Result

class MusicViewController: UIViewController {

    let playlistIds = [
        /*
        "PLFgquLnL59alW3xmYiWRaoz0oM3H17Lth", // New Music This Week
        "PLFgquLnL59ak5gmnz28ZiMd59ryeTPXjT", // Emerging Sounds
        "PLFgquLnL59akA2PflFpeQG9L01VFg90wS", // Latest Music Videos
        "PLDcnymzs18LVXfO_x0Ei0R24qDbVtyy66", // Top Pop Music Tracks
        "PLhd1HyMTk3f5yqcPXjLo8qroWJiMMFBSk", // Top Rock Tracks
        "PLH6pfBXQXHECUaIU3bu9rjG2L6Uhl5A2q", // Top Hip Hop Music Tracks
        "PL47oRh0-pTosOOeXrM-VgAn8ZdPWi3DSW", // Top Alternative Rock Tracks
        "PLFRSDckdQc1vSGAfqrDfeakxi9BTg-8-9", // Top Contemporary R&B Tracks
        "PLVXq77mXV53_3HqhCLGv4mz3oVGYd2Aup", // Top Classical Music Tracks
        "PLvLX2y1VZ-tEmqtENBW39gdozqFCN_WZc", // Top Country Music Tracks
        "PLS_oEMUyvA72meu6iIMd70pHe2_uIeF9E", // Top Reggaeton Tracks
        "PLMcThd22goGZoKIj4VAX4GCoYjoCNLiTC", // Top Jazz Tracks
        "PLTDluH66q5mr5Ibdww8l0ImZg6jWMT3R0", // Top K-Pop Tracks
        "PLhInz4M-OzRX96VZlkhDs9s1WuyQvKKTL", // Top House Music Tracks
        "PLWNXn_iQ2yrIE-txPYCsmdmRJv-iSTPsL", // Top Rhythm & Blues Tracks
        "PLcfQmtiAG0X_byEjBwRXaGJ9WoJL_ntNr", // Top Latin American Music Tracks
        "PLFbKRa_kS4i852ZBCW0XyrVEZzanMFY2a", // Top Folk Music Tracks
        "PLPogFqzUrNuGThbpD4m2uKHQvA7G5y2_B", // Top Dubstep Tracks
        "PLQog_FHUHAFVRsO4otlwzn0bZspSAefOl", // Top Soul Music Tracks
        "PLzauiyXIK7Rj1h23BPvDb3sQwmzHhRuyX", // Top Blues Tracks
        "PLFgquLnL59amXJGk8qUBA_5pvYlr9x53K", // Hungry Hits
        */
        "PLFgquLnL59alJAK6gWHt-QNloshBk3AAh", // The Daily 40
        "PLFgquLnL59amuJEYnzXUxiZw5UXCVhWkn", // Latest
        "PLFgquLnL59akxb6yWTTNMSZ0-d051B4kL", // On The Rise
        "PLFPg_IUxqnZNnACUGsfn50DySIOVSkiKI", // Electronic
        "PLcfQmtiAG0X-fmM85dPlql5wfYbmFumzQ", // Latin
        "PLDcnymzs18LWrKzHmzrGH1JzLBqrHi3xQ", // Pop
        "PL47oRh0-pTouthHPv6AbALWPvPJHlKiF7", // Alternative
        "PLL4IwRtlZcbvbCM7OmXGtzNoSR0IyVT02", // Trap
        "PLYAYp5OI4lRLf_oZapf5T5RUZeUcF9eRO", // Reggae
        "PLH6pfBXQXHEC2uDmDy5oi3tHW6X8kZ2Jo", // Hip Hop
        "PLvLX2y1VZ-tFJCfRG7hi_OjIAyCriNUT2", // Country
        "PLFRSDckdQc1th9sUu8hpV1pIbjjBgRmDw", // R&B
        "PLr8RdoI29cXIlkmTAQDgOuwBhDh3yJDBQ", // Pop Rock
        "PL0zQrw6ZA60Z6JT4lFH-lAq5AfDnO2-aE", // Pop
        "PLfY-m4YMsF-OM1zG80pMguej_Ufm8t0VC", // Heavy Metal
        // "https://www.youtube.com/playlist?list=PLXupg6NyTvTxw5-_rzIsBgqJ2tysQFYt5", // Mexican
        "PLQog_FHUHAFUDDQPOTeAWSHwzFV1Zz5PZ", // Soul
        "PLVXq77mXV53-Np39jM456si2PeTrEm9Mj", // Classic
    ]
    var playlists = [Playlist]()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerNib(UINib(nibName: "PlaylistTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaylistTableViewCell")
            tableView.allowsSelectionDuringEditing = true
        }
    }

    convenience init() {
        self.init(nibName: "MusicViewController", bundle: NSBundle.mainBundle())
    }

    override func viewDidLoad() {
        fetch()
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension MusicViewController {

    func fetch() {
        YouTubeKit.playlists(parameters: ["id": playlistIds.joinWithSeparator(",")]) { result in
            switch result {
            case .Success(let playlists):
                self.playlists = playlists
                GCDBlock.async(.Main) {
                //Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let error):
                Alert.error(error)
            }
        }
    }

}

extension MusicViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let playlist = playlists[indexPath.row]
        let cell  = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell", forIndexPath: indexPath) as! PlaylistTableViewCell
        cell.configure(playlist)
        return cell
    }
}

extension MusicViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = PlaylistViewController()
        controller.playlist = playlists[indexPath.row]
        controller.navigatable = true
        controller.showChannel = false
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

// MARK: Scroll to top
extension MusicViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarTouched:", name: StatusBarTouchedNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StatusBarTouchedNotification, object: nil)
    }

    func statusBarTouched(notification: NSNotification) {
        if tableView.numberOfSections > 0 && tableView.numberOfRowsInSection(0) > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

}