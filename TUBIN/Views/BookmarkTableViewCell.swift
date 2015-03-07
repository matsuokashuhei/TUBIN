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
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(bookmark: Bookmark) {
        switch bookmark.name {
        case "playlist":
            let playlist = bookmark.item as Playlist
            playlist.thumbnailImage() { (result) -> Void in
                switch result {
                case .Success(let box):
                    self.thumbnailImageView.image = box.unbox
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
                case .Failure(let box):
                    self.logger.error(box.unbox.localizedDescription)
                }
            }
            titleLabel.text = channel.title
            channelTitleLabel.hidden = true
        default:
            thumbnailImageView.hidden = true
            titleLabel.text = bookmark.name
            channelTitleLabel.hidden = true
        }
    }
}
