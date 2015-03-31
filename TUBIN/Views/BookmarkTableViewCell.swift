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

}
