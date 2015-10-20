//
//  History.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import YouTubeKit
import SwiftyUserDefaults
import RealmSwift

class History: Object {

    dynamic var watchedAt = NSDate()
    dynamic var id = ""
    dynamic var _video: RLMVideo!

    var video: Video {
        return _video.toItem()
    }

    override class func primaryKey() -> String? {
        return "id"
    }

}

extension History {

    class func new(watchedAt watchedAt: NSDate, video: Video) -> History {
        let history = History()
        history.watchedAt = watchedAt
        history.id = video.id
        history._video = video.toObject()
        return history
    }

    class func all() -> [History] {
        do {
            let results = try Realm().objects(History).sorted("watchedAt", ascending: false)
            var histories = [History]()
            for history in results {
                histories.append(history)
            }
            return histories
        } catch let error as NSError {
            // TODO:
            return [History]()
        }
    }

    class func create(video: Video) {
        do {
            let realm = try Realm()
            try realm.write {
                if let history = realm.objectForPrimaryKey(History.self, key: video.id) {
                    realm.delete(history)
                }
                let history = History.new(watchedAt: NSDate(), video: video)
                realm.add(history)
                let results = realm.objects(History).sorted("watchedAt", ascending: false)
                if results.count > Defaults["maxNumberOfHistories"].int! {
                    realm.delete(results.first!)
                }
            }
        } catch let error as NSError {
            // TODO:
        }
    }

    class func destroy(histories: [History]) {
        do {
            let realm = try Realm()
            try realm.write {
                for history in histories {
                    realm.delete(history)
                }
            }
        } catch let error as NSError {
            // TODO:
        }
    }
}
