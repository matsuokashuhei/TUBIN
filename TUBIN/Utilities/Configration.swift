//
//  Configration.swift
//  Tubin
//
//  Created by matsuosh on 2015/02/18.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

class Configration: NSObject {

    class var sharedInstance: Configration {
        struct Singleton {
            static let instance = Configration()
        }
        return Singleton.instance
    }

    struct Defaults {
        static let maxNumberOfSubscribes = 19
        static let maxNumberOfFavorites = 20
        static let maxNumberOfHistories = 30
    }

}