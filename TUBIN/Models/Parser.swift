//
//  ParseClient.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/20.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import LlamaKit

class Parser {

    class func configure() {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("nZZspCtivBttgR2EfrVpZMJNfYcWKvCdVT4WbjYD", clientKey: "1faakaiSg32P6fDKAO1rZGZDIatTOTmFDKsZaTe5")
        //PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        let key = "initializedBookmarks"
        if NSUserDefaults.standardUserDefaults().boolForKey(key) == false {
            let names = ["popular", "search", "favorites", "guide"]
            //let names = ["Popular", "Guide"]
            for (index, name) in enumerate(names) {
                let bookmark = PFObject(className: "Bookmark")
                bookmark["index"] = index + 1
                bookmark["name"] = name
                bookmark.pin()
            }
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: key)
        }
    }

    class func save(object: PFObject, handler: (Result<Bool, NSError>) -> Void) {
        object.pinInBackgroundWithBlock { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                handler(.Failure(Box(error)))
            }
        }
    }

    class func save(objects: [PFObject], handler: (Result<Bool, NSError>) -> Void) {
        PFObject.pinAllInBackground(objects) { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                handler(.Failure(Box(error)))
            }
        }
    }

    class func destroy(object: PFObject, handler: (Result<Bool, NSError>) -> Void) {
        object.unpinInBackgroundWithBlock { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                handler(.Failure(Box(error)))
            }
        }
    }

    class func destroy(objects: [PFObject], handler: (Result<Bool, NSError>) -> Void) {
        PFObject.unpinAllInBackground(objects, block: { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                handler(.Failure(Box(error)))
            }
        })
    }

    // MARK: - Static functions

    class var sharedInstance: Parser {
        struct Singleton {
            static let instance = Parser()
        }
        return Singleton.instance
    }

    func query(className: String) -> PFQuery {
        var query = PFQuery(className: className)
        query.fromLocalDatastore()
        return query
    }

    enum Error {
        case Unknown
        func toNSError() -> NSError {
            return NSError(domain: "ParserErrorDomain", code: 99999, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."])
        }
    }
}