//
//  Content.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import YouTubeKit
import LlamaKit
import Parse

class Bookmark {

    var index: Int
    let name: String
    var item: Item?
    var collection: Collection?

    init(object: PFObject) {
        index = object["index"] as! Int
        name = object["name"] as! String
        if name == "playlist" {
            item = Playlist(object: object)
        }
        if name == "channel" {
            item = Channel(object: object)
        }
        if name == "collection" {
            collection = Collection(object: object)
        }
    }

    func toPFObject() -> PFObject {
        if name == "playlist" {
            let playlist = item as! Playlist
            let object = playlist.toPFObject(className: "Bookmark")
            object["index"] = index
            object["name"] = name
            return object
        }
        if name == "channel" {
            let channel = item as! Channel
            let object = channel.toPFObject(className: "Bookmark")
            object["index"] = index
            object["name"] = name
            return object
        }
        if name == "collection" {
            let object = collection!.toPFObject(className: "Bookmark")
            object["id"] = collection!.id
            object["index"] = index
            object["name"] = name
            return object
        }
        let object = PFObject(className: "Bookmark")
        object["index"] = index
        object["name"] = name
        return object
    }
}

// MARK: - Class functions
extension Bookmark {

    class func all() -> Result<[Bookmark], NSError> {
        let query = Parser.sharedInstance.query("Bookmark")
        query.addAscendingOrder("index")
        if let objects = query.findObjects() as? [PFObject] {
            let bookmarks = objects.map { (object) -> Bookmark in
                return Bookmark(object: object)
            }
            return .Success(Box(bookmarks))
        } else {
            return .Failure(Box(Parser.Error.Unknown.toNSError()))
        }
    }

    class func all(handler: (Result<[Bookmark], NSError>) -> Void) {
        all { (result: Result<[PFObject], NSError>) -> Void in
            switch result {
            case .Success(let box):
                let bookmarks = box.unbox.map { (object) -> Bookmark in
                    return Bookmark(object: object)
                }
                handler(.Success(Box(bookmarks)))
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

    class func all(handler: (Result<[PFObject], NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Bookmark")
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

    class func all(#skip: Int, handler: (Result<[Bookmark], NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Bookmark")
        query.addAscendingOrder("index")
        query.skip = skip
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let objects = objects as? [PFObject] {
                let bookmarks = objects.map { (object) -> Bookmark in
                    return Bookmark(object: object)
                }
                handler(.Success(Box(bookmarks)))
                return
            }
            if let error = error {
                handler(.Failure(Box(error)))
                return
            }
            handler(.Failure(Box(Parser.Error.Unknown.toNSError())))
        }
    }

    class func find(#id: String, handler: (Result<[PFObject], NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Bookmark")
        query.whereKey("id", equalTo: id)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
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

    class func add(playlist: Playlist, handler: (Result<Bool, NSError>) -> Void) {
        let object = playlist.toPFObject(className: "Bookmark")
        object["name"] = "playlist"
        add(object: object, handler: handler)
    }

    class func add(channel: Channel, handler: (Result<Bool, NSError>) -> Void) {
        let object = channel.toPFObject(className: "Bookmark")
        object["name"] = "channel"
        add(object: object, handler: handler)
    }

    class func add(collection: Collection, handler: (Result<Bool, NSError>) -> Void) {
        let object = collection.toPFObject(className: "Bookmark")
        object["name"] = "collection"
        add(object: object, handler: handler)
    }

    class func add(#object: PFObject, handler: (Result<Bool, NSError>) -> Void) {
        let id = object["id"] as! String
        exists(id: id as String) { (result) in
            switch result {
            case .Success(let box):
                let exists = box.unbox
                if exists {
                    handler(.Success(Box(true)))
                } else {
                    self.count { (result) in
                        switch result {
                        case .Success(let box):
                            object["index"] = box.unbox + 1
                            Parser.save(object) { (result) in
                                handler(result)
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

    class func exists(#id: String, handler: (Result<Bool, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Bookmark")
        query.whereKey("id", equalTo: id)
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if let error = error {
                handler(.Failure(Box(error)))
            } else {
                handler(.Success(Box(count > 0)))
            }
        }
    }

    class func count(handler: (Result<Int, NSError>) -> Void) {
        let query = Parser.sharedInstance.query("Bookmark")
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if let error = error {
                handler(.Failure(Box(error)))
            } else {
                handler(.Success(Box(Int(count))))
            }
        }
    }

    class func reset(bookmarks: [Bookmark], handler: (Result<Bool, NSError>) -> Void) {
        all() { (result: Result<[PFObject], NSError>) in
            switch result {
            case .Success(let box):
                Parser.destroy(box.unbox) { (result) in
                    switch result {
                    case .Success(let box):
                        var objects = [PFObject]()
                        for (index, bookmark) in enumerate(bookmarks) {
                            bookmark.index = index + 1
                            objects.append(bookmark.toPFObject())
                        }
                        /*
                        let objects = bookmarks.map { (bookmark) -> PFObject in
                            return bookmark.toPFObject()
                        }
                        */
                        Parser.save(objects, handler: { (result) -> Void in
                            handler(result)
                        })
                    case .Failure(let box):
                        handler(.Failure(box))
                    }
                }
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

}