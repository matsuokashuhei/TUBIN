//
//  UserPlaylistTableViewCell.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(collection: Collection) {
        if let thumbnailURL = collection.thumbnailURL, URL = NSURL(string: thumbnailURL) {
            thumbnailImageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: nil) { (image, error, imageURL) -> () in
                if let image = image {
                    let rect = CGImageCreateWithImageInRect(image.CGImage, self.standardToWide(image.size))
                    self.thumbnailImageView.image = UIImage(CGImage: rect)
                }
            }
            thumbnailImageView.alpha = 1
        } else {
            thumbnailImageView.alpha = 0.5
            thumbnailImageView.backgroundColor = Appearance.sharedInstance.theme.textColor.colorWithAlphaComponent(0.1)
            thumbnailImageView.image = UIImage(named: "ic_favorite_outline_48px")?.imageWithRenderingMode(.AlwaysTemplate)
            thumbnailImageView.contentMode = .ScaleAspectFit
            titleLabel.text = NSLocalizedString("Favorites", comment: "Favorites")
        }
        titleLabel.text = collection.title
        videoCountLabel.text = "\(collection.videoIds.count) " + NSLocalizedString("videos", comment: "videos")
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
