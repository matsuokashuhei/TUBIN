//
//  History.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import LlamaKit
import YouTubeKit
import SwiftyUserDefaults
import XCGLogger

class History {

    let logger = XCGLogger.defaultInstance()

    var watchedAt: NSDate
    var video: Video

    init(watchedAt: NSDate, video: Video) {
        self.watchedAt = watchedAt
        self.video = video
    }

    init(object: PFObject) {
        watchedAt = object["watchedAt"] as! NSDate
        video = Video(object: object)
    }

    func toPFObject() -> PFObject {
        var object = video.toPFObject(className: "History")
        object["watchedAt"] = watchedAt
        return object
    }

}

extension History {

    class func all(handler: (Result<[History], NSError>) -> Void) {
        let query = Parser.sharedInstance.query("History")
        query.addDescendingOrder("watchedAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let objects = objects as? [PFObject] {
                let histories = objects.map { (object) -> History in
                    return History(object: object)
                }
                handler(.Success(Box(histories)))
                return
            }
            if let error = error {
                handler(.Failure(Box(error)))
                return
            }
            handler(.Failure(Box(Parser.Error.Unknown.toNSError())))
        }
    }

    class func find(#id: String, handler: (Result<PFObject, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("History")
        query.whereKey("id", equalTo: id)
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let object = object {
                handler(.Success(Box(object)))
                return
            }
            if let error = error {
                handler(.Failure(Box(error)))
                return
            }
            handler(.Failure(Box(Parser.Error.Unknown.toNSError())))
        }
    }

    class func exists(video: Video, handler: (Result<Bool, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("History")
        query.whereKey("id", equalTo: video.id)
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if let error = error {
                handler(.Failure(Box(error)))
            } else {
                handler(.Success(Box(count > 0)))
            }
        }
    }

    class func add(video: Video, handler: (Result<Bool, NSError>) -> Void) {
        exists(video) { (result) -> Void in
            switch result {
            case .Success(let box):
                let exists = box.unbox
                if exists {
                    self.find(id: video.id, handler: { (result) -> Void in
                        switch result {
                        case .Success(let box):
                            Parser.destroy(box.unbox) { (result) -> Void in
                                switch result {
                                case .Success(let box):
                                    break
                                case .Failure(let box):
                                    handler(.Failure(box))
                                    return
                                }
                            }
                        case .Failure(let box):
                            handler(.Failure(box))
                            return
                        }
                    })
                }
                var object = video.toPFObject(className: "History")
                object["watchedAt"] = NSDate()
                Parser.save(object, handler: { (result) -> Void in
                    switch result {
                    case .Success(let box):
                        //handler(.Success(Box(true)))
                        self.destroy({ (result) -> Void in
                            handler(result)
                        })
                    case .Failure(let box):
                        handler(.Failure(box))
                    }
                })
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

    class func destory(histories: [History], handler: (Result<Bool, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("History")
        query.whereKey("id", containedIn: histories.map { (history) -> String in
            return history.video.id
        })
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                Parser.destroy(objects, handler: { (result) -> Void in
                    handler(result)
                })
            } else {
                if let error = error {
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Failure(Box(Parser.Error.Unknown.toNSError())))
                }
            }
        }
    }

    class func destroy(handler: (Result<Bool, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("History")
        query.addDescendingOrder("watchedAt")
        query.skip = Defaults["maxNumberOfHistories"].int!
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let objects = objects as? [PFObject] {
                if objects.count > 0 {
                    Parser.destroy(objects, handler: { (result) -> Void in
                        handler(result)
                    })
                } else {
                    handler(.Success(Box(true)))
                }
            } else {
                if let error = error {
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Failure(Box(Parser.Error.Unknown.toNSError())))
                }
            }
        }
    }
}