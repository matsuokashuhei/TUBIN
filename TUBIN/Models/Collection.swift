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
        return split(videoIds) { $0 == "," }
    }

    override static func primaryKey() -> String? {
        return "title"
    }

    func save() {
        let realm = Realm()
        realm.write {
            realm.add(self)
        }
    }

    func set(#videos: [Video]) {
        let realm = Realm()
        realm.write {
            if let video = videos.first {
                self.thumbnailURL = video.thumbnailURL
            } else {
                self.thumbnailURL = ""
            }
            self.videoIds = ",".join(videos.map() { (video) -> String in video.id })
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
        var arrayedIds = split(videoIds) { $0 == "," }
        if contains(arrayedIds, video.id) {
            return
        }
        let realm = Realm()
        realm.write {
            if arrayedIds.count == 0 {
                self.thumbnailURL = video.thumbnailURL
            }
            arrayedIds.append(video.id)
            self.videoIds = ",".join(arrayedIds)
        }
    }

}

extension Collection {

    class func setUp() -> () {
        let realm = Realm()
        realm.write {
            realm.add(self.new(index: 0, title: NSLocalizedString("WATCH IT LATER", comment: "WATCH IT LATER")))
        }
    }

    class func migrate() -> () {
        var query = PFQuery(className: "Collection")
        query.fromLocalDatastore()
        query.addAscendingOrder("index")
        if let objects = query.findObjects() as? [PFObject] {
            let realm = Realm()
            realm.write {
                for object in objects {
                    if let index = object["index"] as? Int, let title = object["title"] as? String, let videoIds = object["videoIds"] as? [String] {
                        let collection = Collection()
                        collection.index = index
                        collection.title = title
                        if let thumbnailURL = object["thumbnailURL"] as? String {
                            collection.thumbnailURL = thumbnailURL
                        }
                        collection.videoIds = ",".join(videoIds)
                        realm.add(collection)
                    }
                }
            }
        }
    }

    class func new(#index: Int, title: String) -> Collection {
        let collection = Collection()
        collection.index = index
        collection.title = title
        return collection
    }

    class func create(#index: Int, title: String, videos: [Video]) {
        let realm = Realm()
        realm.write {
            let collection = Collection()
            collection.index = index
            collection.title = title
            if let video = videos.first {
                collection.thumbnailURL = video.thumbnailURL
            }
            collection.videoIds = ",".join(videos.map { (video) in video.id })
            realm.add(collection)
        }
    }

    class func all() -> [Collection] {
        let results = Realm().objects(Collection).sorted("index")
        var collections = [Collection]()
        for collection in results {
            collections.append(collection)
        }
        return collections 
    }

    class func exists(#title: String) -> Bool {
        if let collection = Realm().objectForPrimaryKey(Collection.self, key: title) {
            return true
        } else {
            return false
        }
    }

}