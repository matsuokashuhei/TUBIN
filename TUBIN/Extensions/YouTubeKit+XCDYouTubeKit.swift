//
//  YouTubeKit+XCDYouTubeKit.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import YouTubeKit
import Result
import XCDYouTubeKit

extension Video {

    enum Quality: Int {
        case Low = 36
        case Medium = 18
        case High = 22
        case FullHigh = 37
    }

    func streamURL(handler: (Result<NSURL, NSError>) -> Void) {
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(id) { (video, error) -> Void in
            if let error = error {
                handler(.Failure(error))
                return
            }
            if let video = video {
                for quality in [Quality.FullHigh, Quality.High, Quality.Medium, Quality.Low] {
                    if let streamURL = video.streamURLs[quality.rawValue] as? NSURL {
                        handler(.Success(streamURL))
                        return
                    }
                }
                let error = NSError(domain: "XCDYouTubeKitErrorDomain", code: 99999, userInfo: [NSLocalizedDescriptionKey: "XCDYouTubeKit did not return streamURL."])
                handler(.Failure(error))
            } else {
                let error = NSError(domain: "XCDYouTubeKitErrorDomain", code: 99999, userInfo: [NSLocalizedDescriptionKey: "XCDYouTubeKit did not return video."])
                handler(.Failure(error))
            }
        }
    }

}