//
//  Favorite.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/25.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Alamofire
import LlamaKit
import YouTubeKit
import XCGLogger

class Favorite {

    let logger = XCGLogger.defaultInstance()

    var index: Int
    var video: Video

    init(index: Int, video: Video) {
        self.index = index
        self.video = video
    }

    init(object: PFObject) {
        index = object["index"] as! Int
        video = Video(object: object)
    }

    func toPFObject() -> PFObject {
        var object = video.toPFObject(className: "Favorite")
        object["index"] = index
        return object
    }

}

// MARK: - Class functions
extension Favorite {

    class func find(#id: String) -> PFObject? {
        let query = Parser.sharedInstance.query("Favorite")
        query.whereKey("id", equalTo: id)
        return query.getFirstObject()
    }

    class func find(#id: String, handler: (Result<PFObject, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Favorite")
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

    class func all(handler: (Result<[Favorite], NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Favorite")
        query.addAscendingOrder("index")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let objects = objects as? [PFObject] {
                let favorites = objects.map { (object) -> Favorite in
                    return Favorite(object: object)
                }
                handler(.Success(Box(favorites)))
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
        let query = Parser.sharedInstance.query("Favorite")
        query.whereKey("id", equalTo: video.id)
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if let error = error {
                handler(.Failure(Box(error)))
            } else {
                handler(.Success(Box(count > 0)))
            }
        }
    }

    class func count(handler: (Result<Int, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Favorite")
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if let error = error {
                handler(.Failure(Box(error)))
            } else {
                handler(.Success(Box(Int(count))))
            }
        }
    }

    class func add(video: Video, handler: (Result<Bool, NSError>) -> Void) {
        exists(video) { (result) in
            switch result {
            case .Success(let box):
                let exists = box.unbox
                if exists {
                    return
                } else {
                    self.count { (result) in
                        switch result {
                        case .Success(let box):
                            var object = video.toPFObject(className: "Favorite")
                            object["index"] = box.unbox + 1
                            Parser.save(object) { (result) in
                                switch result {
                                case .Success(let box):
                                    handler(.Success(Box(true)))
                                case .Failure(let box):
                                    handler(.Failure(box))
                                }
                            }
                        case .Failure(let box):
                            handler(.Failure(box))
                        }
                    }
                }
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

    class func remove(video: Video, handler: (Result<Bool, NSError>) -> Void) {
        Favorite.exists(video) { (result) in
            switch result {
            case .Success(let box):
                let exists = box.unbox
                if exists {
                    Favorite.find(id: video.id) { (result) in
                        switch result {
                        case .Success(let box):
                            box.unbox.unpinInBackgroundWithBlock() { (succeeded, error) in
                                if succeeded {
                                    handler(.Success(Box(true)))
                                } else {
                                    if let error = error {
                                        handler(.Failure(Box(error)))
                                    } else {
                                        handler(.Failure(Box(Parser.Error.Unknown.toNSError())))
                                    }
                                }
                            }
                        case .Failure(let box):
                            handler(.Failure(box))
                        }
                    }
                } else {
                    handler(.Success(Box(true)))
                }
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

    class func edit(#updates: [Favorite], removes: [Favorite]) -> Result<Bool, NSError> {
        for (index, favorite) in enumerate(updates) {
            if favorite.index == index + 1 {
                continue
            }
            if let object = Favorite.find(id: favorite.video.id) {
                object["index"] = index + 1
                if object.pin() {
                } else {
                    return .Failure(Box(Parser.Error.Unknown.toNSError()))
                }
            }
        }
        for favorite in removes {
            if let object = Favorite.find(id: favorite.video.id) {
                if object.unpin() {
                } else {
                    return .Failure(Box(Parser.Error.Unknown.toNSError()))
                }
            }
        }
        return .Success(Box(true))
    }

}