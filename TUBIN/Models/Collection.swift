//
//  Playlist.swift
//  TUBIN
//
//  Created by matsuosh on 2015/04/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

//import Result
//import Box
import YouTubeKit
import RealmSwift
import XCGLogger

import Parse

class Collection: Object {

    let logger = XCGLogger.defaultInstance()

    dynamic var index = 0
    dynamic var title = ""
    dynamic var thumbnailURL = ""
    dynamic var videoIds = ""

    var videoCount: Int {
        return arrayedVideoIds.count
    }

    private var arrayedVideoIds: [String] {
        return videoIds.componentsSeparatedByString(",")
        //return split(videoIds.characters) { $0 == "," }
    }

    /*
    override static func primaryKey() -> String? {
        return "title"
    }
    */

    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            logger.error(error.description)
        }
    }

    func set(videos videos: [Video]) {
        do {
            let realm = try Realm()
            try realm.write {
                if let video = videos.first {
                    self.thumbnailURL = video.thumbnailURL
                } else {
                    self.thumbnailURL = ""
                }
                self.videoIds = videos.map() { (video) -> String in video.id }.joinWithSeparator(",")
            }
        } catch let error as NSError {
            logger.error(error.description)
        }
    }

    func insert(video: Video, atIndex: Int) {
        var arrayedIds = arrayedVideoIds
        arrayedIds.insert(video.id, atIndex: atIndex)
        if atIndex == 0 {
            thumbnailURL = video.thumbnailURL
        }
    }

    func add(video: Video) {
        var arrayedIds = videoIds.componentsSeparatedByString(",")
        if arrayedIds.contains(video.id) {
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                if arrayedIds.count == 0 {
                    self.thumbnailURL = video.thumbnailURL
                }
                arrayedIds.append(video.id)
                self.videoIds = arrayedIds.joinWithSeparator(",")
            }
        } catch let error as NSError {
            logger.error(error.description)
        }
    }

}

extension Collection {

    class func setUp() -> () {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self.new(index: 0, title: NSLocalizedString("WATCH IT LATER", comment: "WATCH IT LATER")))
            }
        } catch let error as NSError {
            XCGLogger.defaultInstance().error(error.description)
        }
    }

    class func migrate() -> () {
        do {
            let query = PFQuery(className: "Collection")
            query.fromLocalDatastore()
            query.addAscendingOrder("index")
            let objects = try query.findObjects()
            let realm = try Realm()
            try realm.write {
                for object in objects {
                    if let index = object["index"] as? Int, let title = object["title"] as? String, let videoIds = object["videoIds"] as? [String] {
                        let collection = Collection()
                        collection.index = index
                        collection.title = title
                        if let thumbnailURL = object["thumbnailURL"] as? String {
                            collection.thumbnailURL = thumbnailURL
                        }
                        collection.videoIds = videoIds.joinWithSeparator(",")
                        realm.add(collection)
                    }
                }
            }
        } catch let error as NSError {
            XCGLogger.defaultInstance().error(error.description)
        }
    }

    class func new(index index: Int, title: String) -> Collection {
        let collection = Collection()
        collection.index = index
        collection.title = title
        return collection
    }

    class func create(index index: Int, title: String, videos: [Video]) {
        do {
            let realm = try Realm()
            try realm.write {
                let collection = Collection()
                collection.index = index
                collection.title = title
                if let video = videos.first {
                    collection.thumbnailURL = video.thumbnailURL
                }
                collection.videoIds = videos.map { (video) in video.id }.joinWithSeparator(",")
                realm.add(collection)
            }
        } catch let error as NSError {
            XCGLogger.defaultInstance().error(error.description)
        }
    }

    class func all() -> [Collection] {
        do {
            let results = try Realm().objects(Collection).sorted("index")
            let collections = results.map { (result) -> Collection in result }
            return collections
        } catch let error as NSError {
            XCGLogger.defaultInstance().error(error.description)
            return [Collection]()
        }
    }

    class func exists(title title: String) -> Bool {
        return try! Realm().objects(Collection.self).filter("title = '\(title)'").count > 0
        /*
        //if let collections = Realm().objects(Collection.self).filter("title = '\(title)'") {
            return true
        } else {
            return false
        }
        */
    }

}