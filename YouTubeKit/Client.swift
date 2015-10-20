//
//  Client.swift
//  YouTubeKit
//
//  Created by matsuosh on 2015/02/26.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Alamofire

class Client {

    static var sharedInstance = Client()

    var maxResults: Int = 25

    func suggestions(keyword keyword: String, handler: (Result<[String], NSError>) -> Void) {
        let request = Alamofire.request(API.Suggestions(keyword: keyword))
        debugPrint(request)
        request.responseJSON { (response) in
            switch response.result {
            case .Success(let value):
                if let JSON = value as? NSArray {
                    var suggestions = [String]()
                    if let keywords = JSON[1] as? NSArray {
                        for keyword in keywords {
                            if let keyword = keyword as? NSArray {
                                if let suggestion = keyword[0] as? String {
                                    suggestions.append(suggestion)
                                }
                            }
                        }
                    }
                    handler(.Success(suggestions))
                } else {
                    handler(.Failure(ResponseError.Unknown.toNSError()))
                }
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func search<T: APIDelegate>(parameters parameters: [String: String], handler: (Result<(page: Page, items: [T]), NSError>) -> Void) {
        var _parameters = parameters
        _parameters["type"] = T.type
        _parameters["maxResults"] = "\(maxResults)"
        let request = Alamofire.request(API.Search(parameters: _parameters))
        debugPrint(request)
        request.responseJSON { (response) in
            switch self.validate(response) {
            case .Success(let JSON):
                let page = Page(JSON: JSON)
                guard let items = JSON["items"] as? [NSDictionary] else {
                    handler(.Success((page: page, items: [T]())))
                    return
                }
                let ids = items.flatMap { item -> String? in
                    guard let id = item["id"] as? NSDictionary else {
                        return nil
                    }
                    return id["\(T.type)Id"] as? String
                }
                let parameters = ["id": ids.joinWithSeparator(",")]
                self.find(parameters: parameters) { (response: Result<[T], NSError>) -> Void in
                    switch response {
                    case .Success(let value):
                        handler(.Success((page: page, items: value)))
                    case .Failure(let error):
                        handler(.Failure(error))
                    }
                }
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func find<T: APIDelegate>(parameters parameters: [String: String], handler: (Result<[T], NSError>) -> Void) {
        let request = Alamofire.request(T.callAPI(parameters))
        debugPrint(request)
        request.responseJSON { (response)in
            switch self.validate(response) {
            case .Success(let JSON):
                guard let itemsInJSON = JSON["items"] as? [NSDictionary] else {
                    handler(.Success([T]()))
                    return
                }
                let items = itemsInJSON.flatMap({ (itemInJSON) -> T? in
                    return T(JSON: itemInJSON)
                })
                handler(.Success(items))
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func plyalistItems(parameters parameters: [String: String], handler: (Result<(page: Page, items: [Video]), NSError>) -> Void) {
        var _parameters = parameters
        _parameters["maxResults"] = "\(maxResults)"
        let request = Alamofire.request(API.PlaylistItems(parameters: _parameters))
        debugPrint(request)
        request.responseJSON { (response) in
            switch self.validate(response) {
            case .Success(let JSON):
                let page = Page(JSON: JSON)
                guard let items = JSON["items"] as? [NSDictionary] else {
                    handler(.Success((page: page, items: [Video]())))
                    return
                }
                let ids: [String] = items.map { item -> String in
                    let contentDetails = item["contentDetails"] as! NSDictionary
                    return contentDetails["videoId"] as! String
                }
                let parameters = ["id": ids.joinWithSeparator(",")]
                self.find(parameters: parameters) { (response: Result<[Video], NSError>) -> Void in
                    switch response {
                    case .Success(let value):
                        handler(.Success((page: page, items: value)))
                    case .Failure(let error):
                        handler(.Failure(error))
                    }
                }
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func guideCategories(handler: (Result<[GuideCategory], NSError>) -> Void) {
        let request = Alamofire.request(API.GuideCategories())
        debugPrint(request)
        request.responseJSON { (response) in
            switch self.validate(response) {
            case .Success(let JSON):
                guard let items = JSON["items"] as? [NSDictionary] else {
                    handler(.Success([GuideCategory]()))
                    return
                }
                let categories = items.map { (item) -> GuideCategory in
                    return GuideCategory(JSON: item)
                }
                handler(.Success(categories))
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func videos(parameters parameters: [String: String], handler: (Result<(page: Page, videos: [Video]), NSError>) -> Void) {
        var _parameters = parameters
        _parameters["maxResults"] = "\(maxResults)"
        let request = Alamofire.request(API.Videos(parameters: _parameters))
        debugPrint(request)
        request.responseJSON { (response) in
            switch self.validate(response) {
            case .Success(let JSON):
                let page = Page(JSON: JSON)
                guard let items = JSON["items"] as? [NSDictionary] else {
                    handler(.Success((page: page, videos: [Video]())))
                    return
                }
                let videos = items.flatMap { (item) -> Video? in
                    return Video(JSON: item)
                }
                handler(.Success((page: page, videos: videos)))
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func channels(parameters parameters: [String: String], handler: (Result<(page: Page, channels: [Channel]), NSError>) -> Void) {
        var _parameters = parameters
        _parameters["maxResults"] = "\(maxResults)"
        let request = Alamofire.request(API.Channels(parameters: _parameters))
        debugPrint(request)
        request.responseJSON { (response) in
            switch self.validate(response) {
            case .Success(let JSON):
                let page = Page(JSON: JSON)
                guard let items = JSON["items"] as? [NSDictionary] else {
                    handler(.Success(page: page, channels: [Channel]()))
                    return
                }
                let channels = items.flatMap { (item) -> Channel? in
                    return Channel(JSON: item)
                }
                handler(.Success((page: page, channels: channels)))
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    private func validate(response: Response<AnyObject, NSError>) -> Result<NSDictionary, NSError> {
        switch response.result {
        case .Success(let value):
            guard let JSON = value as? NSDictionary else {
                return .Failure(ResponseError.Unknown.toNSError())
            }
            if let error = Error(JSON: JSON) {
                return .Failure(error.toNSError())
            }
            return .Success(JSON)
        case .Failure(let error):
            return .Failure(error)
        }
    }

    private func validate(object: AnyObject?) -> Result<NSDictionary, NSError> {
        if let JSON = object as? NSDictionary {
            if let error = Error(JSON: JSON) {
                return .Failure(error.toNSError())
            }
            return .Success(JSON)
        } else {
            return .Failure(ResponseError.Unknown.toNSError())
        }
    }
}