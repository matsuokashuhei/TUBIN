//
//  History.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import LlamaKit
import YouTubeKit

class History {

    let logger = XCGLogger.defaultInstance()

    var watchedAt: NSDate
    var video: Video

    init(watchedAt: NSDate, video: Video) {
        self.watchedAt = watchedAt
        self.video = video
    }

    init(object: PFObject) {
        watchedAt = object["watchedAt"] as NSDate!
        video = Video(object: object)
    }

    func toPFObject() -> PFObject {
        var object = video.toPFObject(className: "History")
        object["watchedAt"] = watchedAt
        return object
    }

}

extension History {

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
                if box.unbox {
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
                        handler(.Success(Box(true)))
                    case .Failure(let box):
                        handler(.Failure(box))
                    }
                })
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }
}