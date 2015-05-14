//
//  UIImage+TUBIN.swift
//  TUBIN
//
//  Created by matsuosh on 2015/05/14.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

extension UIImage {

    func resizeToWide() -> UIImage {
        func resizeToWide() -> CGRect {
            let width = size.width
            let height = CGFloat(CGFloat(size.width / 16) * 9)
            let x = CGFloat(0)
            let y = CGFloat((size.height - height) / 2)
            //return CGRect(x: x, y: y, width: width, height: height)
            return CGRect(x: x, y: y, width: width, height: height)
        }
        let wideRect = resizeToWide()
        let wideCGImage = CGImageCreateWithImageInRect(CGImage, wideRect)
        return UIImage(CGImage: wideCGImage)!
    }

}