//
//  UIImage+TUBIN.swift
//  TUBIN
//
//  Created by matsuosh on 2015/05/14.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import XCGLogger

extension UIImage {

    func resizeToWide() -> UIImage {
        return self
        /*
        func resizeToWide() -> CGRect {
            let width = size.width
            let height = CGFloat(CGFloat(size.width / 16) * 9)
            let x = CGFloat(0)
            let y = CGFloat((size.height - height) / 2)
            //return CGRect(x: x, y: y, width: width, height: height)
            return CGRect(x: x, y: y, width: width, height: height)
        }
        let wideRect = resizeToWide()
        if let wideCGImage = CGImageCreateWithImageInRect(CGImage, wideRect) {
            return UIImage(CGImage: wideCGImage)
        } else {
            return self
        }
        */
        /*
        XCGLogger.defaultInstance().verbose("size: \(size)")
        let rect: CGRect = {
            //let size = CGSize(width: self.size.width, height: self.size.width * (9 / 16))
            let width = self.size.width
            let height = self.size.width * (9 / 16)
            let x: CGFloat = 0
            let y: CGFloat = (self.size.height - height) / 2
            return CGRect(x: x, y: y, width: width, height: height)
        }()
        XCGLogger.defaultInstance().verbose("rect: \(rect)")
        guard
            let wideCGImage = CGImageCreateWithImageInRect(self.CGImage, rect) else {
            //let wideImage = UIImage(CGImage: wideCGImage) else {
            return self
        }
        let wideImage = UIImage(CGImage: wideCGImage)
        return wideImage
        //return UIImage(CGImage: wideCGImage)
        */
    }

}