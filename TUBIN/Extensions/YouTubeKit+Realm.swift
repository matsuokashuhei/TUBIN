//
//  YouTubeKit+Realm.swift
//  TUBIN
//
//  Created by matsuosh on 2015/06/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import YouTubeKit
import RealmSwift

class RLMVideo: Object {
    dynamic var id = ""
    dynamic var publishedAt = NSDate()
    dynamic var title = ""
    dynamic var thumbnailURL = ""
    dynamic var channelId = ""
    dynamic var channelTitle = ""
    dynamic var viewCount = ""
    dynamic var duration = ""
    func toItem() -> Video {
        return Video(id: id, publishedAt: publishedAt, title: title, description: "", thumbnailURL: thumbnailURL, channelId: channelId, channelTitle: channelTitle, viewCount: (viewCount as NSString).longLongValue, duration: duration)
    }
}

extension Video {

    func toObject() -> RLMVideo {
        let video = RLMVideo()
        video.id = id
        if let publishedAt = publishedAt {
            video.publishedAt = publishedAt
        }
        video.title = title
        video.thumbnailURL = thumbnailURL
        video.channelId = channelId
        video.channelTitle = channelTitle
        video.viewCount = "\(viewCount)"
        video.duration = duration
        return video
    }
}

class RLMPlaylist: Object {
    dynamic var id = ""
    dynamic var publishedAt = NSDate()
    dynamic var title = ""
    dynamic var thumbnailURL = ""
    dynamic var channelId = ""
    dynamic var channelTitle = ""
    dynamic var itemCount = 0
    func toItem() -> Playlist {
        return Playlist(id: id, publishedAt: publishedAt, title: title, description: "", thumbnailURL: thumbnailURL, channelId: channelId, channelTitle: channelTitle, itemCount: itemCount)
    }
}

extension Playlist {
    func toObject() -> RLMPlaylist {
        let playlist = RLMPlaylist()
        playlist.id = id
        if let publishedAt = publishedAt {
            playlist.publishedAt = publishedAt
        }
        playlist.title = title
        playlist.thumbnailURL = thumbnailURL
        playlist.channelId = channelId
        playlist.channelTitle = channelTitle
        if let itemCount = itemCount {
            playlist.itemCount = itemCount
        }
        return playlist
    }
}

class RLMChannel: Object {
    dynamic var id = ""
    dynamic var publishedAt = NSDate()
    dynamic var title = ""
    dynamic var thumbnailURL = ""
    dynamic var viewCount = 0
    dynamic var subscriberCount = 0
    dynamic var videoCount = 0
    func toItem() -> Channel {
        return Channel(id: id, publishedAt: publishedAt, title: title, description: "", thumbnailURL: thumbnailURL, viewCount: viewCount, subscriberCount: subscriberCount, videoCount: videoCount)
    }
}

extension Channel {
    func toObject() -> RLMChannel {
        let channel = RLMChannel()
        channel.id = id
        if let publishedAt = publishedAt {
            channel.publishedAt = publishedAt
        }
        channel.title = title
        channel.thumbnailURL = thumbnailURL
        if let viewCount = viewCount {
            channel.viewCount = viewCount
        }
        if let subscriberCount = subscriberCount {
            channel.subscriberCount = subscriberCount
        }
        if let videoCount = videoCount {
            channel.videoCount = videoCount
        }
        return channel
    }
}
