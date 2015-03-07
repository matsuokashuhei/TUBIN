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

class Favorite {

    let logger = XCGLogger.defaultInstance()

    var index: Int
    var video: Video

    init(index: Int, video: Video) {
        self.index = index
        self.video = video
    }

    init(object: PFObject) {
        index = object["index"] as Int!
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
                self.count({ (result) -> Void in
                    switch result {
                    case .Success(let box):
                        var object = video.toPFObject(className: "Favorite")
                        object["index"] = box.unbox + 1
                        Parser.save(object, handler: { (result) -> Void in
                            switch result {
                            case .Success(let box):
                                video.download({ (result) in
                                    switch result {
                                    case .Success(let box):
                                        handler(.Success(Box(true)))
                                    case .Failure(let box):
                                        handler(.Failure(box))
                                    }
                                })
                            case .Failure(let box):
                                handler(.Failure(box))
                                return
                            }
                        })
                    case .Failure(let box):
                        handler(.Failure(box))
                        return
                    }
                })
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }

    /*
    class func add(video: SwifTube.Video, completion: (succeeded: Bool, error: NSError!) -> Void) {
        // 重複してたら事前に削除する。
        let query = Parser.sharedInstance.query("Favorite")
        query.whereKey("id", equalTo: video.id)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let error = error {
                // エラー
                completion(succeeded: false, error: error)
                return
            }
            if let objects = objects {
                PFObject.unpinAllInBackground(objects, block: { (succeeded, error) -> Void in
                    // ダウンロード
                    Favorite.download(video, completion: { (destinationURL, error) -> Void in
                        if let destinationURl = destinationURL {
                            //video.fileURL = destinationURl
                            // すべてのお気に入りを入手して、これから追加するビデオのindexを決める。
                            Favorite.count { (count, error) in
                                if let error = error {
                                    // エラー
                                    completion(succeeded: false, error: error)
                                    return
                                }
                                var favorite = Favorite(index: count + 1, video: video)
                                let object = favorite.toPFObject()
                                // お気に入りにビデオを保存する。
                                object.pinInBackgroundWithBlock { (succeeded, error) in
                                    if succeeded {
                                        // TODO: 通知
                                        completion(succeeded: true, error: nil)
                                    } else {
                                        // エラー
                                        if let error = error {
                                            completion(succeeded: false, error: error)
                                        } else {
                                            completion(succeeded: false, error: nil)
                                        }
                                    }
                                }
                            }
                        } else {
                            if let error = error {
                                completion(succeeded: false, error: error)
                            } else {
                                completion(succeeded: false, error: nil)
                            }
                        }
        
                    })
                })
            }
            completion(succeeded: false, error: nil)
        }
    }
    */

    class func edit(#updates: [Favorite], removes: [Favorite]) -> Result<Bool, NSError> {
        for (index, favorite) in enumerate(updates) {
            if favorite.index == index + 1 {
                continue
            }
            if let object = Favorite.find(id: favorite.video.id) {
                object["index"] = index + 1
                if object.pin() {
                    continue
                } else {
                    return .Failure(Box(Parser.Error.Unknown.toNSError()))
                }
            }
        }
        for favorite in removes {
            if let object = Favorite.find(id: favorite.video.id) {
                if object.unpin() {
                    if FileManager.existsFile(favorite.video.fileName()) {
                        var error: NSError?
                        FileManager.remove(favorite.video.fileName()) { (result)  in
                            switch result {
                            case .Success(let box):
                                break
                            case .Failure(let box):
                                error = box.unbox
                            }
                        }
                        if let error = error {
                            return .Failure(Box(error))
                        }
                    }
                } else {
                    return .Failure(Box(Parser.Error.Unknown.toNSError()))
                }
            }
        }
        return .Success(Box(true))
    }

    /*
    class func edit(#updates: [Favorite], removes: [Favorite]) -> (succeeded: Bool, error: NSError!) {
        var succeeded = true
        for (index, favorite) in enumerate(updates) {
            if favorite.index == index + 1 {
                continue
            }
            if let object = Favorite.find(id: favorite.video.id) {
                object["index"] = index + 1
                if !object.pin() {
                    succeeded = false
                }
            }
        }
        for favorite in removes {
            if let object = Favorite.find(id: favorite.video.id) {
                if object.unpin() {
                    if let fileURL = favorite.fileURL {
                        var error: NSError?
                        NSFileManager.defaultManager().removeItemAtURL(fileURL, error: &error)
                        if let error = error {
                            Logger.error(error.description)
                            succeeded = false
                        }
                    }
                } else {
                    succeeded = false
                }
            }
        }
        return (succeeded: succeeded, error: nil)
    }
    */

    /*
    class func storedIn(video: SwifTube.Video, completion: (fileURL: NSURL?) -> Void) {
        var fileURL: NSURL?
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            fileURL = directoryURL.URLByAppendingPathComponent("Caches").URLByAppendingPathComponent("\(video.id).mp4")
        }
        if let fileURL = fileURL {
            if let path = fileURL.path {
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    completion(fileURL: fileURL)
                } else {
                    completion(fileURL: nil)
                }
            } else {
                completion(fileURL: nil)
            }
        } else {
            completion(fileURL: nil)
        }
    }

    class func download(video: SwifTube.Video, completion: (fileURL: NSURL!, error: NSError!) -> Void) {
        ViewHelper.showLoadingIndicator(true)
        video.streamURL(completion: { (streamURL, error) -> Void in
            ViewHelper.showLoadingIndicator(false)
            if let error = error {
                completion(fileURL: nil, error: error)
            }
            if let streamURL = streamURL {
                var fileURL: NSURL?
                let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = { (temporaryURL, response) in
                    if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                        fileURL = directoryURL.URLByAppendingPathComponent("Caches").URLByAppendingPathComponent("\(video.id).mp4")
                        return fileURL!
                    } else {
                        return temporaryURL
                    }
                }
                ViewHelper.showLoadingIndicator(true)
                Alamofire.download(.GET, streamURL, destination).response { (_, _, _, error) in
                    ViewHelper.showLoadingIndicator(false)
                    if let error = error {
                        completion(fileURL: nil, error: error)
                        return
                    }
                    completion(fileURL: fileURL, error: nil)
                }
            } else {
                completion(fileURL: nil, error: nil)
            }
        })
    }
    */

}