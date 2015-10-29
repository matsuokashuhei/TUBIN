//
//  ItemTableTableViewCell.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/21.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit

import Alamofire
import XCGLogger

class ItemTableTableViewCell: UITableViewCell {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(item: Item) {
        titleLabel.text = item.title
    }

    private func formatStringFromInt(integer: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.stringFromNumber(NSNumber(integer: integer))!
    }

    private func formatStringFromInt64(longLong: Int64) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.stringFromNumber(NSNumber(longLong: longLong))!
    }

    private func formatStringFromInt(longLong: String) -> String {
        return formatStringFromInt64(NSString(string: longLong).longLongValue)
    }

}

class VideoTableViewCell: ItemTableTableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        item.thumbnailImage { (result) in
            switch result {
            case .Success(let image):
                self.thumbnailImageView.image = image.toWide()
            case .Failure(let error):
                self.logger.error(error.description)
            }
        }
        /*
        if let URL = NSURL(string: item.thumbnailURL) {
            Alamofire.request(.GET, URL).responseData { (response) in
                switch response.result {
                case .Success(let data):
                    if let image = UIImage(data: data) {
                        self.thumbnailImageView.image = image.toWide()
                    }
                case .Failure(let error):
                    self.logger.error(error.description)
                }
            }
        }
        */
        let video = item as! Video
        durationLabel.text = video.duration
        if let publishedAt = video.publishedAt {
            publishedAtLabel.text = publishedAt.relativeTimeToString()
        } else {
            publishedAtLabel.text = ""
        }
        viewCountLabel.text = "\(formatStringFromInt64(video.viewCount)) " + NSLocalizedString("views", comment: "views")
        channelTitleLabel.text = video.channelTitle
    }
}

class PlaylistTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        item.thumbnailImage { (result) in
            switch result {
            case .Success(let image):
                self.thumbnailImageView.image = image.toWide()
            case .Failure(let error):
                self.logger.error(error.description)
            }
        }
        let playlist = item as! Playlist
        channelTitle.text = playlist.channelTitle
        if let itemCount = playlist.itemCount {
            itemCountLabel.text = "\(formatStringFromInt(itemCount)) " + NSLocalizedString("videos", comment: "videos")
        } else {
            itemCountLabel.text = ""
        }
    }

}

class ChannelTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var subscriberCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        item.thumbnailImage { (result) in
            switch result {
            case .Success(let image):
                self.thumbnailImageView.image = image
                self.thumbnailImageView.contentMode = .ScaleAspectFit
            case .Failure(let error):
                self.logger.error(error.description)
            }
        }
        /*
        if let URL = NSURL(string: item.thumbnailURL) {
            thumbnailImageView.af_setImageWithURL(URL)
            thumbnailImageView.contentMode = .ScaleAspectFit
        }
        */
        let channel = item as! Channel
        if let subscriberCount = channel.subscriberCount {
            subscriberCountLabel.text = "\(formatStringFromInt(subscriberCount)) subscribes"
            subscriberCountLabel.text = "\(formatStringFromInt(subscriberCount)) " + NSLocalizedString("subscribes", comment: "subscribes")
        } else {
            subscriberCountLabel.text = ""
        }
        if let videoCount = channel.videoCount {
            videoCountLabel.text = "\(formatStringFromInt(videoCount)) " + NSLocalizedString("videos", comment: "videos")
        } else {
            videoCountLabel.text = ""
        }
    }

}
