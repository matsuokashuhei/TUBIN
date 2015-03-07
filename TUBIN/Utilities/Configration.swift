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
    
    var backgroundColor: UIColor

    override init() {
        backgroundColor = UIColor.darkGrayColor()
    }

}