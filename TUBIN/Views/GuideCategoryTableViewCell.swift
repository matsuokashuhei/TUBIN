//
//  GuideCategoryTableViewCell.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/01.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import LlamaKit
import YouTubeKit
import XCGLogger

class GuideCategoryTableViewCell: UITableViewCell {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(category: GuideCategory) {
        titleLabel.text = category.title
        if let channel = category.channel {
            if let URL = NSURL(string: channel.thumbnailURL) {
                thumbnailImageView.kf_setImageWithURL(URL, placeholderImage: nil, optionsInfo: nil) { (image, error, cacheType, imageURL) -> () in
                    if let image = image {
                        self.thumbnailImageView.image = image
                        self.thumbnailImageView.contentMode = .ScaleAspectFit
                    }
                }
            }
        }
    }
}
