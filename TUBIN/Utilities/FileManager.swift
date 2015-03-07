//
//  FileManager.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/01.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Alamofire
import LlamaKit
import YouTubeKit

class FileManager {

    enum Error {
        case Unknown
        func toNSError() -> NSError {
            return NSError(domain: "FileManagerErrorDomain", code: 99999, userInfo: [NSLocalizedDescriptionKey: ""])
        }
    }
    class func fileURL(fileName: String) -> NSURL? {
        var fileURL: NSURL?
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            fileURL = directoryURL.URLByAppendingPathComponent("Caches").URLByAppendingPathComponent(fileName)
        }
        return fileURL
    }

    class func existsFile(fileName: String) -> Bool {
        return exists(fileURL(fileName))
    }

    class func exists(fileURL: NSURL?) -> Bool {
        if let fileURL = fileURL {
            if let path = fileURL.path {
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    return true
                }
            }
        }
        return false
    }

    class func remove(fileName: String, handler: (Result<Bool, NSError>) -> Void) {
        if let fileURL = fileURL(fileName) {
            if exists(fileURL) {
                remove(fileURL) { (result) in
                    handler(result)
                    return
                }
            }
        }
        handler(.Failure(Box(Error.Unknown.toNSError())))
    }
    class func remove(fileURL: NSURL, handler: (Result<Bool, NSError>) -> Void) {
        var error: NSError?
        NSFileManager.defaultManager().removeItemAtURL(fileURL, error: &error)
        if let error = error {
            handler(.Failure(Box(error)))
        } else {
            handler(.Success(Box(true)))
        }
    }

    class func download(sourceURL: NSURL, fileName: String,handler: (Result<Bool, NSError>) -> Void) {
        let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = { (temporaryURL, response) in
            if let fileURL = self.fileURL(fileName) {
                return fileURL
            }
            return temporaryURL
        }
        let request = Alamofire.download(.GET, sourceURL, destination)
        request.response() { (_, _, _, error) in
            if let error = error {
                handler(.Failure(Box(error)))
                return
            }
            handler(.Success(Box(true)))
        }
    }

}