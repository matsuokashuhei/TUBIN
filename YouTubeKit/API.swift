//
//  API.swift
//  YouTubeKit
//
//  Created by matsuosh on 2015/02/26.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import Alamofire

private struct Constants {
    static let key = "AIzaSyBkKOxRcHXfTvMrKHRsWy2cO5dF899agZg"
}

public enum API: URLRequestConvertible {

    case Suggestions(keyword: String)
    case Search(parameters: [String: String])
    case Videos(parameters: [String: String])
    case Playlists(parameters: [String: String])
    case PlaylistItems(parameters: [String: String])
    case Channels(parameters: [String: String])
    case GuideCategories()

    public var URLRequest: NSMutableURLRequest {

        let URL: NSURL! = {
            switch self {
            case .Suggestions(_):
                return NSURL(string: "https://suggestqueries.google.com")
            default:
                return NSURL(string: "https://www.googleapis.com/youtube/v3")
            }
        }()

        let path: String = {
            switch self {
            case .Suggestions(_):
                return "/complete/search"
            case .Search(_):
                return "/search"
            case .Videos(_):
                return "/videos"
            case .Playlists(_):
                return "/playlists"
            case .PlaylistItems(_):
                return "/playlistItems"
            case .Channels(_):
                return "/channels"
            case .GuideCategories():
                return "guideCategories"
            }
        }()

        let parameters: [String: String] = {
            let locale = NSLocale.currentLocale()
            var regionCode = "us"
            if let countryCode = locale.objectForKey(NSLocaleCountryCode) as? String {
                regionCode = countryCode
            }
            var hl = "en_US"
            if let identifier = locale.objectForKey(NSLocaleIdentifier) as? String {
                hl = identifier
            }
            var parameters = [String: String]()
            switch self {
            case .Suggestions(_):
                break
            default:
                parameters["key"] = Constants.key
            }
            switch self {
            case .Suggestions(let keyword):
                parameters["ds"] = "yt"
                parameters["hjson"] = "t"
                parameters["client"] = "youtube"
                parameters["alt"] = "json"
                parameters["q"] = keyword
                parameters["hl"] = hl
                parameters["ie"] = "utf_8"
                parameters["oe"] = "utf_8"
            case .Search(let _parameters):
                parameters["part"] = "snippet"
                parameters["regionCode"] = regionCode
                for (k, v) in _parameters as [String: String] {
                    parameters[k] = v
                }
            case .Videos(let _parameters):
                parameters["part"] = "snippet,contentDetails,statistics"
                parameters["regionCode"] = regionCode
                parameters["hl"] = hl
                for (k, v) in _parameters as [String: String] {
                    parameters[k] = v
                }
            case .Playlists(let _parameters):
                parameters["part"] = "snippet,contentDetails"
                for (k, v) in _parameters as [String: String] {
                    parameters[k] = v
                }
            case .PlaylistItems(let _parameters):
                parameters["part"] = "snippet,contentDetails"
                for (k, v) in _parameters as [String: String] {
                    parameters[k] = v
                }
            case .Channels(let _parameters):
                parameters["part"] = "snippet,contentDetails,statistics"
                for (k, v) in _parameters as [String: String] {
                    parameters[k] = v
                }
            case .GuideCategories():
                parameters["part"] = "snippet"
//                parameters["regionCode"] = regionCode
                parameters["regionCode"] = "us"
//                parameters["hl"] = hl
                parameters["hl"] = "en_US"
            }
            return parameters
        }()
        let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: parameters).0
    }

}