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
import XCGLogger
import Kingfisher

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
        /*
        if let URL = NSURL(string: item.thumbnailURL) {
            thumbnailImageView.sd_setImageWithURL(URL)
        }
        */
        /*
        if let URL = NSURL(string: item.thumbnailURL) {
            SDWebImageManager.sharedManager().downloadImageWithURL(URL, options: SDWebImageOptions.RetryFailed, progress: { (_, _) -> Void in
            }, completed: { (image, error, _, finished, _) -> Void in
                if let image = image {
                    //self.thumbnailImageView.image = image
                    self.thumbnailImageView.image = image
                }
                if let error = error {
                    self.logger.error(error.localizedDescription)
                }
            })
        }
        */
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

    private func standardToWide(standard: CGSize) -> CGRect {
        var wide = CGRectZero
        wide.origin.x = 0
        wide.origin.y = (standard.height / 16.0) * 2
        wide.size.width = standard.width
        wide.size.height = standard.height - (standard.height / 16.0) * 4
        return wide
    }
}

class VideoTableViewCell: ItemTableTableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        /*
        item.thumbnailImage() { (result: Result<UIImage, NSError>) in
            switch result {
            case .Success(let box):
                let image = box.unbox
                let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                self.thumbnailImageView.image = UIImage(CGImage: rect)
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
            }
        }
        */
        if let URL = NSURL(string: item.thumbnailURL) {
            thumbnailImageView.kf_setImageWithURL(URL, placeHolderImage: nil, options: .None) { (image, error, imageURL) -> () in
                if let image = image {
                    let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                    self.thumbnailImageView.image = UIImage(CGImage: rect)
                }
            }
        }
        let video = item as! Video
        durationLabel.text = video.duration
        if let publishedAt = video.publishedAt {
            publishedAtLabel.text = publishedAt.relativeTimeToString()
        } else {
            publishedAtLabel.text = ""
        }
        //viewCountLabel.text = "\(formatStringFromInt64(video.viewCount)) views"
        viewCountLabel.text = "\(formatStringFromInt64(video.viewCount)) " + NSLocalizedString("views", comment: "views")
        channelTitle.text = video.channelTitle
    }
}

class PlaylistTableViewCell: ItemTableTableViewCell {
    
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!

    override func configure(item: Item) {
        super.configure(item)
        /*
        item.thumbnailImage() { (result: Result<UIImage, NSError>) in
            switch result {
            case .Success(let box):
                let image = box.unbox
                let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                self.thumbnailImageView.image = UIImage(CGImage: rect)
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
            }
        }
        */
        if let URL = NSURL(string: item.thumbnailURL) {
            thumbnailImageView.kf_setImageWithURL(URL, placeHolderImage: nil, options: .None) { (image, error, imageURL) -> () in
                if let image = image {
                    let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                    self.thumbnailImageView.image = UIImage(CGImage: rect)
                }
            }
        }
        let playlist = item as! Playlist
        channelTitle.text = playlist.channelTitle
        if let itemCount = playlist.itemCount {
            //itemCountLabel.text = "\(formatStringFromInt(itemCount)) videos"
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
        /*
        item.thumbnailImage() { (result: Result<UIImage, NSError>) in
            switch result {
            case .Success(let box):
                self.thumbnailImageView.image = box.unbox
                self.thumbnailImageView.contentMode = .ScaleAspectFit
            case .Failure(let box):
                self.logger.error(box.unbox.localizedDescription)
            }
        }
        */
        if let URL = NSURL(string: item.thumbnailURL) {
            thumbnailImageView.kf_setImageWithURL(URL, placeHolderImage: nil, options: .None) { (image, error, imageURL) -> () in
                if let image = image {
                    self.thumbnailImageView.image = image
                    self.thumbnailImageView.contentMode = .ScaleAspectFit
                }
            }
        }
        let channel = item as! Channel
        if let subscriberCount = channel.subscriberCount {
            subscriberCountLabel.text = "\(formatStringFromInt(subscriberCount)) subscribes"
            subscriberCountLabel.text = "\(formatStringFromInt(subscriberCount)) " + NSLocalizedString("subscribes", comment: "subscribes")
        } else {
            subscriberCountLabel.text = ""
        }
        if let videoCount = channel.videoCount {
            //videoCountLabel.text = "\(formatStringFromInt(videoCount)) videos"
            videoCountLabel.text = "\(formatStringFromInt(videoCount)) " + NSLocalizedString("videos", comment: "videos")
        } else {
            videoCountLabel.text = ""
        }
    }

}
