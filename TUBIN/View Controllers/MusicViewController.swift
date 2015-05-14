//
//  MusicViewController.swift
//  TUBIN
//
//  Created by matsuosh on 2015/05/14.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import Async
import Result
import Box

class MusicViewController: UIViewController {

    let playlistIds = [
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
        YouTubeKit.playlists(parameters: ["id": ",".join(playlistIds)]) { result in
            switch result {
            case .Success(let box):
                self.playlists = box.value
                Async.main {
                    self.tableView.reloadData()
                }
            case .Failure(let box):
                Alert.error(box.value)
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
