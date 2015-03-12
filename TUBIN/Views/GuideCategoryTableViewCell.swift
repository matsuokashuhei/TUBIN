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
        YouTubeKit.channels(parameters: ["categoryId": category.id, "maxResults": "1"]) { (result: Result<(page: Page, channels: [Channel]), NSError>) in
            switch result {
            case .Success(let box):
                if let channel = box.unbox.channels.first {
                    channel.thumbnailImage() { result in
                        switch result {
                        case .Success(let box):
                            self.thumbnailImageView.image = box.unbox
                        case .Failure(let box):
                            Alert.error(box.unbox)
                        }

                    }
                }
            case .Failure(let box):
                Alert.error(box.unbox)
            }
        }
    }
}
