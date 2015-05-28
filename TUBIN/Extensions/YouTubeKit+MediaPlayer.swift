//
//  YouTubeKit+MediaPlayer.swift
//  TUBIN
//
//  Created by matsuosh on 2015/05/23.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import MediaPlayer
import YouTubeKit
import Kingfisher
import Result
import Box

extension Video {

    func setPlayingInfo() {
        if let URL = NSURL(string: thumbnailURL) {
            ImageDownloader.defaultDownloader.downloadImageWithURL(URL, progressBlock: nil, completionHandler: { (image, error, imageURL) -> () in
                if let image = image {
                    let playingInfo: [NSObject: AnyObject] = [
                        MPMediaItemPropertyTitle: self.title,
                        //MPMediaItemPropertyArtist: self.channelTitle,
                        //MPMediaItemPropertyAlbumTitle: "",
                        MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image),
                    ]
                    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingInfo
                }
            })
        }
    }

    func playingInfo(handler: (Result<[NSObject: AnyObject], NSError>) -> Void) {
        if let URL = NSURL(string: thumbnailURL) {
            ImageDownloader.defaultDownloader.downloadImageWithURL(URL, progressBlock: nil, completionHandler: { (image, error, imageURL) -> () in
                if let image = image {
                    let playingInfo: [NSObject: AnyObject] = [
                        MPMediaItemPropertyTitle: self.title,
                        //MPMediaItemPropertyArtist: self.channelTitle,
                        //MPMediaItemPropertyAlbumTitle: "",
                        MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image),
                    ]
                    handler(.Success(Box(playingInfo)))
                } else {
                    handler(.Failure(Box(NSError())))
                }
            })
        }
    }

}
