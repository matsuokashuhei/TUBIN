//
//  YouTubeKit+Parse.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/28.
//  Copyright (c) 2015蟷ｴ matsuosh. All rights reserved.
//

import Alamofire
import YouTubeKit
import Parse

extension Item {

    /*
    convenience init(object: PFObject) {
    let id = object["id"] as String!
    let publishedAt = object["publishedAt"] as? NSDate
    let title = object["title"] as String!
    let description = object["description"] as String!
    let thumbnailURL = object["thumbnailURL"] as String!
    self.init(id: id, publishedAt: publishedAt, title: title, description: description, thumbnailURL: thumbnailURL)
    }

    func toPFObject(#className: String) -> PFObject {
    var object = PFObject(className: className)
    object["id"] = self.id
    object["title"] = self.title
    object["description"] = self.description
    if let publishedAt = self.publishedAt {
    object["publishedAt"] = publishedAt
    }
    object["thumbnailURL"] = self.thumbnailURL
    return object
    }
    */
}

protocol Parsable {
    init(object: PFObject)
    func toPFObject(className className: String) -> PFObject
}

extension Video {

    convenience init(object: PFObject) {
        let id = object["id"] as! String
        let publishedAt = object["publishedAt"] as? NSDate
        let title = object["title"] as! String
        let description = object["description"] as! String
        let thumbnailURL = object["thumbnailURL"] as! String
        let channelId = object["channelId"] as! String
        let channelTitle = object["channelTitle"] as! String
        let viewCount = (object["viewCount"] as! NSString).longLongValue
        let duration = object["duration"] as! String
        self.init(id: id, publishedAt: publishedAt, title: title, description: description, thumbnailURL: thumbnailURL, channelId: channelId, channelTitle: channelTitle, viewCount: viewCount, duration: duration)
    }

    func toPFObject(className className: String) -> PFObject {
        var object = PFObject(className: className)
        object["id"] = self.id
        object["title"] = self.title
        object["description"] = self.description
        if let publishedAt = self.publishedAt {
            object["publishedAt"] = publishedAt
        }
        object["thumbnailURL"] = self.thumbnailURL
        object["channelTitle"] = channelTitle
        object["channelId"] = channelId
        object["viewCount"] = "\(viewCount)"
        object["duration"] = duration
        return object
    }

}

extension Playlist {

    convenience init(object: PFObject) {
        let id = object["id"] as! String
        let publishedAt = object["publishedAt"] as? NSDate
        let title = object["title"] as! String
        let description = object["description"] as! String
        let thumbnailURL = object["thumbnailURL"] as! String
        let channelId = object["channelId"] as! String
        let channelTitle = object["channelTitle"] as! String
        let itemCount = object["itemCount"] as! Int
        self.init(id: id, publishedAt: publishedAt, title: title, description: description, thumbnailURL: thumbnailURL, channelId: channelId, channelTitle: channelTitle, itemCount: itemCount)
    }

    func toPFObject(className className: String) -> PFObject {
        var object = PFObject(className: className)
        object["id"] = id
        object["title"] = title
        object["description"] = description
        if let publishedAt = publishedAt {
            object["publishedAt"] = publishedAt
        }
        object["thumbnailURL"] = thumbnailURL
        object["channelTitle"] = channelTitle
        object["channelId"] = channelId
        object["itemCount"] = itemCount
        return object
    }

}

extension Channel {

    convenience init(object: PFObject) {
        let id = object["id"] as! String
        let publishedAt = object["publishedAt"] as? NSDate
        let title = object["title"] as! String!
        let description = object["description"] as! String
        let thumbnailURL = object["thumbnailURL"] as! String
        let viewCount = object["viewCount"] as? Int
        let subscriberCount = object["subscriberCount"] as? Int
        let videoCount = object["videoCount"] as? Int
        self.init(id: id, publishedAt: publishedAt, title: title, description: description, thumbnailURL: thumbnailURL, viewCount: viewCount, subscriberCount: subscriberCount, videoCount: videoCount)
    }

    func toPFObject(className className: String) -> PFObject {
        var object = PFObject(className: className)
        object["id"] = id
        object["title"] = title
        object["description"] = description
        if let publishedAt = publishedAt {
            object["publishedAt"] = publishedAt
        }
        object["thumbnailURL"] = thumbnailURL
        object["viewCount"] = viewCount
        object["subscriberCount"] = subscriberCount
        object["videoCount"] = videoCount
        return object
    }

}