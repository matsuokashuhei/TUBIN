//
//  Content.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import YouTubeKit
import RealmSwift
import SwiftyUserDefaults
import Parse

class Bookmark: Object {

    dynamic var index = 0
    dynamic var id = ""
    dynamic var type = ""
    dynamic var title = ""
    dynamic var imageName = ""
    dynamic var _channel: RLMChannel?
    dynamic var _playlist: RLMPlaylist?

    override class func primaryKey() -> String? {
        return "id"
    }

    var channel: Channel? {
        return _channel?.toItem()
    }
    var playlist: Playlist? {
        return _playlist?.toItem()
    }
    var preseted: Bool {
        return contains(["popular", "search", "music", "favorite", "guide"], type)
    }

    var editable: Bool {
        return contains(["playlist", "channel"], type)
    }

}

extension Bookmark {

    class func setUp() -> () {
        // Music
        let music = Bookmark()
        music.type = "music"
        music.title = "Music"
        music.id = "tubin_music"
        music.imageName = "ic_album_48px"
        Bookmark.add(music)
        // Search
        let search = Bookmark()
        search.type = "search"
        search.title = "Search"
        search.id = "tubin_search"
        search.imageName = "ic_search_48px"
        Bookmark.add(search)
        // Popular
        let popular = Bookmark()
        popular.type = "popular"
        popular.title = "Popular"
        popular.id = "tubin_popular"
        popular.imageName = "ic_mood_48px"
        Bookmark.add(popular)
        // Guide
        let guide = Bookmark()
        guide.type = "guide"
        guide.title = "Guide"
        guide.id = "tubin_guide"
        guide.imageName = "ic_map_48px"
        Bookmark.add(guide)
        // Favorite
        let favorite = Bookmark()
        favorite.type = "favorite"
        favorite.title = "Favorite"
        favorite.id = "tubin_favorite"
        favorite.imageName = "ic_favorite_outline_48px"
        Bookmark.add(favorite)
        /*
        let names = ["popular", "music", "search", "guide", "favorites"]
        for (index, name) in enumerate(names) {
            let bookmark = PFObject(className: "Bookmark")
            bookmark["index"] = index + 1
            bookmark["name"] = name
            bookmark.pin()
        }
        */

        // Collection
    }

    class func migrate() -> () {
        var query = PFQuery(className: "Bookmark")
        query.fromLocalDatastore()
        query.addAscendingOrder("index")
        if let objects = query.findObjects() as? [PFObject] {
            for object in objects {
                if let name = object["name"] as? String {
                    if name == "playlist" {
                        let playlist = Playlist(object: object)
                        /*
                        let bookmark = Bookmark()
                        bookmark.type = "playlist"
                        bookmark.id = playlist.id
                        bookmark._playlist = playlist.toObject()
                        */
                        Bookmark.add(playlist)
                    }
                    if name == "channel" {
                        let channel = Channel(object: object)
                        Bookmark.add(channel)
                    }
                }
            }
        }

    }

    /*
    class func new(#type: String, id: String, title: String, thumbnailURL: String) -> Bookmark {
        let bookmark = Bookmark()
        bookmark.type = type
        bookmark.id = id
        bookmark.title = title
        bookmark.thumbnailURL = thumbnailURL
        return bookmark
    }
    */

    class func new(playlist: Playlist) -> Bookmark {
        let bookmark = Bookmark()
        bookmark.type = "playlist"
        bookmark.id = playlist.id
        bookmark._playlist = playlist.toObject()
        return bookmark
    }

    class func new(channel: Channel) -> Bookmark {
        let bookmark = Bookmark()
        bookmark.type = "channel"
        bookmark.id = channel.id
        bookmark._channel = channel.toObject()
        return bookmark
    }

    class func exists(#type: String, id: String) -> Bool {
        let results = Realm().objects(Bookmark).filter("type = '\(type)' AND id = '\(id)'")
        return results.count > 0
    }

    class func all() -> [Bookmark] {
        let results = Realm().objects(Bookmark).sorted("index")
        var bookmarks = [Bookmark]()
        for bookmark in results {
            bookmarks.append(bookmark)
        }
        return bookmarks
    }

    class func add(playlist: Playlist) {
        let bookmark = Bookmark.new(playlist)
        add(bookmark)
    }

    class func add(channel: Channel) {
        let bookmark = Bookmark.new(channel)
        add(bookmark)
    }

    class func add(bookmark: Bookmark) {
        let realm = Realm()
        if let bookmark = realm.objectForPrimaryKey(Bookmark.self, key: bookmark.id) {
            return
        }
        let bookmarks = realm.objects(Bookmark).sorted("index")
        realm.write {
            bookmark.index = bookmarks.count + 1
            realm.add(bookmark)
        }
    }

}