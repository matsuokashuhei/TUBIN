//
//  Playlist.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import LlamaKit
import YouTubeKit

class Collection {

    var id: String {
        return "collection_\(title)"
    }
    var index: Int
    var title: String
    var thumbnailURL: String?
    var videoIds = [String]()

    init(index: Int, title: String) {
        self.index = index
        self.title = title
    }

    init(object: PFObject) {
        index = object["index"] as! Int
        title = object["title"] as! String
        thumbnailURL = object["thumbnailURL"] as? String
        if let videoIds = object["videoIds"] as? [String] {
            self.videoIds = videoIds
        }
    }

    func toPFObject(#className: String) -> PFObject {
        var object = PFObject(className: className)
        object["id"] = id
        object["index"] = index
        object["title"] = title
        if let thumbnailURL = thumbnailURL {
            object["thumbnailURL"] = thumbnailURL
        }
        object["videoIds"] = videoIds
        return object
    }

    func add(video: Video) {
        if contains(videoIds, video.id) {
            return
        }
        if videoIds.count == 0 {
            thumbnailURL = video.thumbnailURL
        }
        videoIds.append(video.id)
    }

    func set(videos: [Video]) {
        /*
        if let video = videos.first {
            thumbnailURL = video.thumbnailURL
        } else {
            thumbnailURL = nil
        }
        */
        thumbnailURL = videos.first?.thumbnailURL
        videoIds = videos.map() { (video) -> String in video.id }
    }

    func insert(video: Video, atIndex: Int) {
        videoIds.insert(video.id, atIndex: atIndex)
        if atIndex == 0 {
            thumbnailURL = video.thumbnailURL
        }
    }

}

extension Collection {

    class func all(handler: (Result<[PFObject], NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Collection")
        query.addAscendingOrder("index")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let objects = objects as? [PFObject] {
                handler(.Success(Box(objects)))
                return
            }
            if let error = error {
                handler(.Failure(Box(error)))
                return
            }
            handler(.Failure(Box(Parser.Error.Unknown.toNSError())))
        }
    }

    class func all(handler: (Result<[Collection], NSError>) -> Void) {
        all { (result: Result<[PFObject], NSError>) in
            switch result {
            case .Success(let box):
                let collections = box.unbox.map { (object) -> Collection in
                    return Collection(object: object)
                }
                handler(.Success(Box(collections)))
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

    class func find(collection: Collection, handler: (Result<PFObject, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Collection")
        query.whereKey("title", equalTo: collection.title)
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
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

    class func count(collection: Collection, handler: (Result<Int, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Collection")
        query.whereKey("title", equalTo: collection.title)
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if let error = error {
                handler(.Failure(Box(error)))
            } else {
                handler(.Success(Box(Int(count))))
            }
        }
    }

    class func create(collection: Collection, handler: (Result<Bool, NSError>) -> Void) {
        Parser.save(collection.toPFObject(className: "Collection")) { (result) in
            handler(result)
        }
    }

    class func save(collection: Collection, handler: (Result<Bool, NSError>) -> Void) {
        find(collection) { (result) in
            switch result {
            case .Success(let box):
                let object = box.unbox
                if let thumbnailURL = collection.thumbnailURL {
                    object["thumbnailURL"] = collection.thumbnailURL
                } else {
                    object.removeObjectForKey("thumbnailURL")
                }
                if collection.videoIds.count > 0 {
                    object["videoIds"] = collection.videoIds
                } else {
                    object.removeObjectForKey("videoIds")
                }
                Parser.save(object) { (result) in
                    handler(result)
                }
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

    class func deleteAll(handler: (Result<Bool, NSError>) -> Void) {
        all() { (result: Result<[PFObject], NSError>) in
            switch result {
            case .Success(let box):
                Parser.destroy(box.unbox) { (result) in
                    handler(result)
                }
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

}