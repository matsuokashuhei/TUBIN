//
//  YouTubeKit.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Alamofire

public func suggestions(keyword keyword: String, handler: (Result<[String], NSError>) -> Void) {
    Client.sharedInstance.suggestions(keyword: keyword, handler: handler)
}

public func search(parameters parameters: [String: String], handler: (Result<(page: Page, items: [Video]), NSError>) -> Void) {
    Client.sharedInstance.search(parameters: parameters, handler: handler)
}

public func search(parameters parameters: [String: String], handler: (Result<(page: Page, items: [Playlist]), NSError>) -> Void) {
    Client.sharedInstance.search(parameters: parameters, handler: handler)
}

public func search(parameters parameters: [String: String], handler: (Result<(page: Page, items: [Channel]), NSError>) -> Void) {
    Client.sharedInstance.search(parameters: parameters, handler: handler)
}

public func playlistItems(parameters parameters: [String: String], handler: (Result<(page: Page, items: [Video]), NSError>) -> Void) {
    Client.sharedInstance.plyalistItems(parameters: parameters, handler: handler)
}

public func guideCategories(handler: (Result<[GuideCategory], NSError>) -> Void) {
    Client.sharedInstance.guideCategories(handler)
}

public func videos(parameters parameters: [String: String], handler: (Result<(page: Page, videos: [Video]), NSError>) -> Void) {
    Client.sharedInstance.videos(parameters: parameters, handler: handler)
}

public func playlists(parameters parameters: [String: String], handler: (Result<[Playlist], NSError>) -> Void) {
    Client.sharedInstance.find(parameters: parameters, handler: handler)
}

public func channels(parameters parameters: [String: String], handler: (Result<(page: Page, channels: [Channel]), NSError>) -> Void) {
    Client.sharedInstance.channels(parameters: parameters, handler: handler)
}

public enum ResponseError {
    case Unknown
    func toNSError() -> NSError {
        switch self {
        case .Unknown:
            return NSError(domain: "YouTubeKitErrorDomain", code: 999999, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."])
        }
    }
}
