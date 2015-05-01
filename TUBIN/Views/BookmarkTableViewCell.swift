//
//  BookmarkTableViewCell.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit
import XCGLogger
import Kingfisher

class BookmarkTableViewCell: UITableViewCell {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(bookmark: Bookmark) {
        switch bookmark.name {
        case "playlist":
            let playlist = bookmark.item as! Playlist
            if let URL = NSURL(string: playlist.thumbnailURL) {
                /*
                thumbnailImageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: nil) { (image, error, imageURL) -> () in
                    if let image = image {
                        let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                        self.thumbnailImageView.image = UIImage(CGImage: rect)
                    }
                }
                */
                thumbnailImageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    if let image = image {
                        let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                        self.thumbnailImageView.image = UIImage(CGImage: rect)
                    }
                })
            }
            titleLabel.text = playlist.title
            channelTitleLabel.text = playlist.channelTitle
        case "channel":
            let channel = bookmark.item as! Channel
            if let URL = NSURL(string: channel.thumbnailURL) {
                thumbnailImageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    if let image = image {
                        let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                        self.thumbnailImageView.image = UIImage(CGImage: rect)
                        self.thumbnailImageView.contentMode = .ScaleAspectFit
                    }
                })
            }
            titleLabel.text = channel.title
            channelTitleLabel.hidden = true
        case "collection":
            let collection = bookmark.collection!
            if let thumbnailURL = collection.thumbnailURL, let URL = NSURL(string: thumbnailURL) {
                thumbnailImageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    if let image = image {
                        let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                        self.thumbnailImageView.image = UIImage(CGImage: rect)
                    }
                })
            }
            titleLabel.text = collection.title
            channelTitleLabel.hidden = true
        case "favorites":
            thumbnailImageView.image = UIImage(named: "ic_favorite_outline_48px")?.imageWithRenderingMode(.AlwaysTemplate)
            thumbnailImageView.contentMode = .ScaleAspectFit
            titleLabel.text = NSLocalizedString("Favorites", comment: "Favorites")
            channelTitleLabel.hidden = true
        case "popular":
            thumbnailImageView.image = UIImage(named: "ic_mood_48px")?.imageWithRenderingMode(.AlwaysTemplate)
            thumbnailImageView.contentMode = .ScaleAspectFit
            titleLabel.text = NSLocalizedString("Popular", comment: "Popular")
            channelTitleLabel.hidden = true
        case "search":
            thumbnailImageView.image = UIImage(named: "ic_search_48px")?.imageWithRenderingMode(.AlwaysTemplate)
            thumbnailImageView.contentMode = .ScaleAspectFit
            titleLabel.text = NSLocalizedString("Search", comment: "Search")
            channelTitleLabel.hidden = true
        case "guide":
            thumbnailImageView.image = UIImage(named: "ic_map_48px")?.imageWithRenderingMode(.AlwaysTemplate)
            thumbnailImageView.contentMode = .ScaleAspectFit
            titleLabel.text = NSLocalizedString("Guide", comment: "Guide")
            channelTitleLabel.hidden = true
        default:
            thumbnailImageView.hidden = true
            titleLabel.text = bookmark.name
            channelTitleLabel.hidden = true
        }
    }

    private func standardToWide(standard: CGSize) -> CGRect {
        var wide = CGRectZero
        wide.origin.x = 0
        wide.origin.y = (standard.height / 16.0) * 2
        wide.size.width = standard.width
        wide.size.height = standard.height - (standard.height / 16.0) * 4
        return wide
    }

    // TODO: iOS 8 のバグを解消するためのコードである。バグが直っていたら消す。
    override func prepareForReuse() {
        // http://stackoverflow.com/questions/24334305/uitableviewcell-reorder-control-disappearing-when-table-is-scrolled
        super.prepareForReuse()
        setEditing(false, animated: false)
    }

}
