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
        if let URL = NSURL(string: collection.thumbnailURL) where URL.absoluteString?.isEmpty == false {
            thumbnailImageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                if let image = image {
                    self.thumbnailImageView.image = image.resizeToWide()
                }
            })
            thumbnailImageView.alpha = 1
        } else {
            thumbnailImageView.alpha = 0.5
            thumbnailImageView.backgroundColor = Appearance.sharedInstance.theme.textColor.colorWithAlphaComponent(0.1)
            thumbnailImageView.image = UIImage(named: "ic_favorite_outline_48px")?.imageWithRenderingMode(.AlwaysTemplate)
            thumbnailImageView.contentMode = .ScaleAspectFit
            //titleLabel.text = NSLocalizedString("Favorites", comment: "Favorites")
        }
        titleLabel.text = collection.title
        videoCountLabel.text = "\(collection.videoCount) " + NSLocalizedString("videos", comment: "videos")
    }

}
