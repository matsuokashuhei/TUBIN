//
//  Appearance.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

class Appearance {

    class func apply(theme: Theme) {
        sharedInstance.apply(theme)
    }

    class func tintColor() -> UIColor {
        return sharedInstance.theme.tintColor()
    }

    enum Theme {
        case Light
        case Dark

        func tintColor() -> UIColor {
            switch self {
            case .Light:
                return UIColor.azureColor()
            case .Dark:
                return UIColor.jellyBeanColor()
            }
        }

        func backgroundColor() -> UIColor {
            switch self {
            case .Light:
                return UIColor.snowColor()
            case .Dark:
                return UIColor.jetColor()
            }
        }

        func fontColor() -> UIColor {
            switch self {
            case .Light:
                return UIColor.jetColor()
            case .Dark:
                return UIColor.whiteColor()
            }
        }
    }

    var theme: Theme

    class var sharedInstance: Appearance {
        struct Singleton {
            static let instance = Appearance()
        }
        return Singleton.instance
    }

    init() {
        theme = .Light
    }

    func apply(theme: Theme) {

        self.theme = theme

        // 外観
        let tintColor = theme.tintColor()
        let backgroundColor = theme.backgroundColor()
        let fontColor = theme.fontColor()
        // Status bar
        /*
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 20))
        statusBarView.backgroundColor = backgroundColor
        window?.rootViewController?.view.addSubview(statusBarView)
        */
        UINavigationBar.appearance().barTintColor = backgroundColor
        UINavigationBar.appearance().tintColor = tintColor
        // UITableView
        UITableView.appearance().backgroundColor = backgroundColor
        UITableViewCell.appearance().backgroundColor = backgroundColor
        UITableViewCell.appearance().tintColor = tintColor
        // TabBar
        TabBar.appearance().tintColor = tintColor
        TabBar.appearance().backgroundColor = backgroundColor
        // UIScrollView
        UIScrollView.appearance().backgroundColor = UIColor.clearColor()
        // Tab
        Tab.appearance().tintColor = tintColor
        Tab.appearance().backgroundColor = backgroundColor
        // ContainerView
        ContainerView.appearance().backgroundColor = backgroundColor
        // UILabel
        UILabel.appearance().textColor = fontColor
        // UISegmentedControl
        UISegmentedControl.appearance().tintColor = tintColor
        UISegmentedControl.appearance().backgroundColor = backgroundColor
        // UIButton
        UIButton.appearance().tintColor = tintColor
        // ScrubberView
        ScrubberView.appearance().tintColor = tintColor
        // UIProgressView
        UIProgressView.appearance().tintColor = tintColor
        // UIActivityIndicatorView
        UIActivityIndicatorView.appearance().color = tintColor
        //ScrubberView.appearance().backgroundColor = backgroundColor
        // ChannelView
        ChannelView.appearance().backgroundColor = backgroundColor
        // SearchViewController, CHannelViewController, PopularViewController, YouTubePlayerViewController
        BackgroundView.appearance().backgroundColor = backgroundColor
        // MiniPlayerView
        MiniPlayerView.appearance().backgroundColor = backgroundColor
    }

}