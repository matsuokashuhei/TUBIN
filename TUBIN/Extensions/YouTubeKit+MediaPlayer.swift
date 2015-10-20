//
//  YouTubeKit+MediaPlayer.swift
//  TUBIN
//
//  Created by matsuosh on 2015/05/23.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import MediaPlayer
import YouTubeKit
//import Result
import Alamofire
import AlamofireImage

extension Video {

    func setPlayingInfo() {
        if let URL = NSURL(string: thumbnailURL) {
            Alamofire.request(.GET, URL).responseImage { (response) in
                switch response.result {
                case .Success(let image):
                    let playingInfo: [String: AnyObject] = [
                        MPMediaItemPropertyTitle: self.title,
                        //MPMediaItemPropertyArtist: self.channelTitle,
                        //MPMediaItemPropertyAlbumTitle: "",
                        MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image),
                    ]
                    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingInfo
                case .Failure(_):
                    break
                }
            }
        }
    }

    func playingInfo(handler: (Result<[String: AnyObject], NSError>) -> Void) {
        if let URL = NSURL(string: thumbnailURL) {
            Alamofire.request(.GET, URL).responseImage { (response) in
                switch response.result {
                case .Success(let image):
                    let playingInfo: [String: AnyObject] = [
                        MPMediaItemPropertyTitle: self.title,
                        //MPMediaItemPropertyArtist: self.channelTitle,
                        //MPMediaItemPropertyAlbumTitle: "",
                        MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: image),
                    ]
                    handler(.Success(playingInfo))
                case .Failure(let error):
                    handler(.Failure(error))
                }
            }
        }
    }

}
