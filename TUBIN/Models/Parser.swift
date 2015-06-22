//
//  ParseClient.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/20.
//  Copyright (c) 2015蟷ｴ matsuosh. All rights reserved.
//

import Foundation
import Result
import Box
import SwiftyUserDefaults
import Parse
import XCGLogger

class Parser {

    let logger = XCGLogger.defaultInstance()

    class func configure() {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("nZZspCtivBttgR2EfrVpZMJNfYcWKvCdVT4WbjYD", clientKey: "1faakaiSg32P6fDKAO1rZGZDIatTOTmFDKsZaTe5")
    }

    class func goodbye() {
        for className in ["Bookmark", "Favorite", "History"] {
            if let objects = PFQuery(className: className).findObjects() as? [PFObject] {
                let result = PFObject.deleteAll(objects)
                if result {
                    XCGLogger.defaultInstance().info("\(className) を削除しました。")
                }
                let count = PFQuery(className: className).countObjects()
                XCGLogger.defaultInstance().info("\(className) のcountObjects()は\(count)個です。")
            }
        }
    }

}