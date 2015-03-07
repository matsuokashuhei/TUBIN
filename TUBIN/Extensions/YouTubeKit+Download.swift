//
//  YouTubeKit+Download.swift
//  Tubin
//
//  Created by matsuosh on 2015/03/01.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//
import Alamofire
import LlamaKit
import YouTubeKit

extension Video {

    public func fileName() -> String {
        return "\(id).mp4"
    }

    public func fileURL() -> NSURL? {
        if let fileURL = FileManager.fileURL(fileName()) {
            if FileManager.exists(fileURL) {
                return fileURL
            }
        }
        return nil
    }

    public func download(handler: (Result<Bool, NSError>) -> Void) {
        streamURL { (result) in
            switch result {
            case .Success(let box):
                FileManager.download(box.unbox, fileName: self.fileName(), handler: { (result) in
                    switch result {
                    case .Success(let box):
                        handler(.Success(Box(true)))
                    case .Failure(let box):
                        handler(.Failure(box))
                    }
                })
            case .Failure(let box):
                handler(.Failure(box))
            }
        }
    }
}