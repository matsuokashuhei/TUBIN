//
//  ItemTableTableViewCell.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/21.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

import LlamaKit
import SDWebImage
import YouTubeKit

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
        if let URL = NSURL(string: item.thumbnailURL) {
            thumbnailImageView.sd_setImageWithURL(URL)
        }
        /*
        if let URL = NSURL(string: item.thumbnailURL) {
            thumbnailImageView.sd_setImageWithURL(URL)
        }
        */
        /*
        item.thumbnailImage() { (result: Result<UIImage, NSError>) in
            switch result {
            case .Success(let box):
                self.thumbnailImageView.image = box.unbox
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
            }
        }
        */
    }

    func formatStringFromInt(integer: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.stringFromNumber(NSNumber(integer: integer))!
    }

    func formatStringFromInt64(longLong: Int64) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.stringFromNumber(NSNumber(longLong: longLong))!
    }

    func formatStringFromInt(longLong: String) -> String {
        return formatStringFromInt64(NSString(string: longLong).longLongValue)
        /*
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.stringFromNumber(NSNumber(longLong: longLong))!
        */
    }
}

class VideoTableViewCell: ItemTableTableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        let video = item as Video
        durationLabel.text = video.duration
        channelTitle.text = video.channelTitle
        video.viewCount
        viewCountLabel.text = "\(formatStringFromInt64(video.viewCount)) views"
    }

    /*
    override func configure(item: SwifTube.Item) {
        super.configure(item)
        let video = item as SwifTube.Video
        durationLabel.text = video.duration
        channelTitle.text = video.channelTitle
        viewCountLabel.text = "\(formatStringFromInt(video.viewCount)) views"
        if let fileURL = video.fileURL {
            //favoriteLabel.text = NSString.awesomeIcon(FaStar)
            favoriteLabel.text = "⭐️"
        } else {
            favoriteLabel.text = ""
        }
    }
    */
}

class PlaylistTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        let playlist = item as Playlist
        channelTitle.text = playlist.channelTitle
        if let itemCount = playlist.itemCount {
            itemCountLabel.text = "\(formatStringFromInt(itemCount)) videos"
        } else {
            itemCountLabel.text = ""
        }
    }

    /*
    override func configure(item: SwifTube.Item) {
        super.configure(item)
        let playlist = item as SwifTube.Playlist
        channelTitle.text = playlist.channelTitle
        if let itemCount = playlist.itemCount {
            itemCountLabel.text = "\(formatStringFromInt(itemCount)) videos"
        } else {
            itemCountLabel.text = ""
        }
    }
    */
}

class ChannelTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var subscriberCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        let channel = item as Channel
        if let subscriberCount = channel.subscriberCount {
            subscriberCountLabel.text = "\(formatStringFromInt(subscriberCount)) subscribes"
        } else {
            subscriberCountLabel.text = ""
        }
        if let videoCount = channel.videoCount {
            videoCountLabel.text = "\(formatStringFromInt(videoCount)) videos"
        } else {
            videoCountLabel.text = ""
        }
    }

    /*
    override func configure(item: SwifTube.Item) {
        super.configure(item)
        /*
        if let viewCount = item.viewCount {
            viewCountLabel.text = "\(formatStringFromInt(viewCount)) views"
        } else {
            viewCountLabel.text = ""
        }
        */
        let channel = item as SwifTube.Channel
        if let subscriberCount = channel.subscriberCount {
            subscriberCountLabel.text = "\(formatStringFromInt(subscriberCount)) subscribes"
        } else {
            subscriberCountLabel.text = ""
        }

        if let videoCount = channel.videoCount {
            videoCountLabel.text = "\(formatStringFromInt(videoCount)) videos"
        } else {
            videoCountLabel.text = ""
        }
    }
    */
}
