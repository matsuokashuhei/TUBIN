//
//  BookmarkTableViewCell.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import YouTubeKit

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
            let playlist = bookmark.item as Playlist
            playlist.thumbnailImage() { (result) -> Void in
                switch result {
                case .Success(let box):
                    let image = box.unbox
                    let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                    self.thumbnailImageView.image = UIImage(CGImage: rect)
                case .Failure(let box):
                    self.logger.error(box.unbox.localizedDescription)
                }
            }
            titleLabel.text = playlist.title
            channelTitleLabel.text = playlist.channelTitle
        case "channel":
            let channel = bookmark.item as Channel
            channel.thumbnailImage() { (result) -> Void in
                switch result {
                case .Success(let box):
                    self.thumbnailImageView.image = box.unbox
                    self.thumbnailImageView.contentMode = .ScaleAspectFit
                case .Failure(let box):
                    self.logger.error(box.unbox.localizedDescription)
                }
            }
            titleLabel.text = channel.title
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
