//
//  ParseClient.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/20.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import LlamaKit
import SwiftyUserDefaults

class Parser {

    class func configure() {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("nZZspCtivBttgR2EfrVpZMJNfYcWKvCdVT4WbjYD", clientKey: "1faakaiSg32P6fDKAO1rZGZDIatTOTmFDKsZaTe5")
        //PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        if !Defaults.hasKey("initializedBookmarks") {
            let names = ["popular", "search", "favorites",]
            for (index, name) in enumerate(names) {
                let bookmark = PFObject(className: "Bookmark")
                bookmark["index"] = index + 1
                bookmark["name"] = name
                bookmark.pin()
            }
            Defaults["initializedBookmarks"] = true
        }
    }

    class func save(object: PFObject, handler: (Result<Bool, NSError>) -> Void) {
        object.pinInBackgroundWithBlock { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                if let error = error {
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Failure(Box(Error.Unknown.toNSError())))
                }
            }
        }
    }

    class func save(objects: [PFObject], handler: (Result<Bool, NSError>) -> Void) {
        PFObject.pinAllInBackground(objects) { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                if let error = error {
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Failure(Box(Error.Unknown.toNSError())))
                }
            }
        }
    }

    class func destroy(object: PFObject, handler: (Result<Bool, NSError>) -> Void) {
        object.unpinInBackgroundWithBlock { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                if let error = error {
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Failure(Box(Error.Unknown.toNSError())))
                }
            }
        }
    }

    class func destroy(objects: [PFObject], handler: (Result<Bool, NSError>) -> Void) {
        PFObject.unpinAllInBackground(objects, block: { (success, error) -> Void in
            if success {
                handler(.Success(Box(success)))
            } else {
                if let error = error {
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Failure(Box(Error.Unknown.toNSError())))
                }
            }
        })
    }

    // MARK: - Static functions

    static var sharedInstance = Parser()

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