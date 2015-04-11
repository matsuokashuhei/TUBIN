//
//  Appearance.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

class Appearance {

//    static var primaryColor = UIColor.clearColor()
//    static var secondaryColor = UIColor.clearColor()
//    static var backgroundColor = UIColor.clearColor()

    struct Font {
        static let name = "AvenirNext-Regular"
    }

    class func apply(theme: Theme) {
        sharedInstance.apply(theme)
    }

    class func tintColor() -> UIColor {
        return sharedInstance.theme.tintColor()
    }

    class func backgroundColor() -> UIColor {
        return sharedInstance.theme.backgroundColor()
    }

    class func textColor() -> UIColor {
        return sharedInstance.theme.textColor()
    }

    class func selectedTextColor() -> UIColor {
        return sharedInstance.theme.selectedTextColor()
    }

    enum Theme {

        case Light
        case Dark

        func tintColor() -> UIColor {
            switch self {
            case .Light:
                //return UIColor.azureColor()j
                //return UIColor.orangeRedColor(alpha: 0.9)
                //return UIColor.bondiBlueColor()
                return UIColor.dodgerBlueColor()
            case .Dark:
                return UIColor.jellyBeanColor()
            }
        }

        func backgroundColor() -> UIColor {
            switch self {
            case .Light:
                return UIColor.whiteColor()
            case .Dark:
                return UIColor.jetColor()
            }
        }

        func textColor() -> UIColor {
            switch self {
            case .Light:
                return UIColor.jetColor()
            case .Dark:
                return UIColor.whiteColor()
            }
        }

        func selectedTextColor() -> UIColor {
            return UIColor.whiteColor()
        }

        func borderColor() -> UIColor {
            //return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            return UIColor.timberwolfCrayolaColor()
        }
    }

    var theme: Theme

    static var sharedInstance = Appearance()

    init() {
        theme = .Light
    }

    func apply(theme: Theme) {

        self.theme = theme

        // 外観
        let tintColor = theme.tintColor()
        let backgroundColor = theme.backgroundColor()
        let textColor = theme.textColor()
        let selectedTextColor = theme.selectedTextColor()
        let borderColor = theme.borderColor()
        // Status bar
        /*
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 20))
        statusBarView.backgroundColor = backgroundColor
        window?.rootViewController?.view.addSubview(statusBarView)
        */

        // UINavigationBar
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: textColor, NSFontAttributeName: UIFont(name: Font.name, size: 15.0)!]
        UINavigationBar.appearance().barTintColor = backgroundColor
        UINavigationBar.appearance().tintColor = tintColor

        // UIBarButtonItem
        UIBarButtonItem.appearance().tintColor = tintColor

        // UITableView
        UITableView.appearance().backgroundColor = UIColor.clearColor()
        UITableView.appearance().separatorColor = borderColor
        UITableView.appearance().tintColor = tintColor

        // UITableViewCell
        UITableViewCell.appearance().backgroundColor = backgroundColor
        UITableViewCell.appearance().tintColor = tintColor
        switch theme {
        case .Light:
            let backgroundView = UIView()
            backgroundView.backgroundColor = tintColor.colorWithAlphaComponent(0.1)
            UITableViewCell.appearance().selectedBackgroundView = backgroundView
            break
        case .Dark:
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.charcoalColor()
            UITableViewCell.appearance().selectedBackgroundView = backgroundView
        }

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
        DarkLabel.appearance().backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        DarkLabel.appearance().textColor = UIColor.whiteColor()

        TextLabel.appearance().textColor = textColor
        SubTextLabel.appearance().textColor = textColor.colorWithAlphaComponent(0.5)
        UILabel.appearance().textColor = textColor

        // UISegmentedControl
        UISegmentedControl.appearance().tintColor = tintColor
        UISegmentedControl.appearance().backgroundColor = backgroundColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: Font.name, size: 12.0)!], forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: backgroundColor, NSFontAttributeName: UIFont(name: Font.name, size: 12.0)!], forState: .Selected)

        // UISlider
        let image = UIImage(named: "ic_bar_24px")?.imageWithRenderingMode(.AlwaysTemplate)
        UISlider.appearance().setThumbImage(image, forState: .Normal)

        // ScrubberView
        ScrubberView.appearance().tintColor = tintColor

        // UIProgressView
        UIProgressView.appearance().tintColor = tintColor

        // UIActivityIndicatorView
        //UIActivityIndicatorView.appearance().color = tintColor

        // UIToolbar
        UIToolbar.appearance().barTintColor = backgroundColor
        UIToolbar.appearance().tintColor = tintColor
        // UIBarButtonItem

        // ChannelView
        ChannelView.appearance().backgroundColor = backgroundColor

        // SearchViewController, CHannelViewController, PopularViewController, YouTubePlayerViewController
        BackgroundView.appearance().backgroundColor = backgroundColor

        // MiniPlayerView
        MiniPlayerView.appearance().backgroundColor = backgroundColor

        // 線
        BorderView.appearance().backgroundColor = borderColor

        // ボタン
        UIButton.appearance().tintColor = tintColor
        NavigationButton.appearance().tintColor = borderColor
        LabelButton.appearance().tintColor = backgroundColor
        LabelButton.appearance().backgroundColor = tintColor

    }

}