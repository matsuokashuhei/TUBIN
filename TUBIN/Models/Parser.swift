//
//  ParseClient.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/20.
//  Copyright (c) 2015蟷ｴ matsuosh. All rights reserved.
//

import Foundation
import Result
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
            let objects = try! PFQuery(className: className).findObjects()
            try! PFObject.deleteAll(objects)
        }
    }

}