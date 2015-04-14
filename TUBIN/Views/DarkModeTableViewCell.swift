//
//  DarkModeTableViewCell.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/15.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

class DarkModeTableViewCell: UITableViewCell {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
