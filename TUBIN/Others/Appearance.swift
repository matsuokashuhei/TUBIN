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

    /*
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

    class func toastColor() -> UIColor {
        return UIColor.redColor()
    }
    */

    enum Theme {

        case Light
        case Dark

        var primaryColor: UIColor {
            return UIColor(hexString: "FC115D")!
        }

        var secondaryColor: UIColor {
            return UIColor(hexString: "524065")!
        }

        var backgroundColor: UIColor {
            switch self {
            case .Light:
                return UIColor(hexString: "FFFFFF")!
            case .Dark:
                return UIColor(hexString: "050113")!
            }
        }

        var selectedTabTextColor: UIColor {
            return primaryColor
        }

        var tabTextColor: UIColor {
            return secondaryColor
            //return primaryColor.colorWithAlphaComponent(0.5)
        }

        var borderColor: UIColor {
            return UIColor.grayColor()
        }

        var textColor: UIColor {
            switch self {
            case .Light:
                return UIColor.blackColor()
            case .Dark:
                return UIColor.whiteColor()
            }
        }

        var statusBarStyle: UIStatusBarStyle {
            switch self {
            case .Light:
                return .Default
            case .Dark:
                return .LightContent
            }
        }
        /*
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
        */
    }

    var theme: Theme

    static var sharedInstance = Appearance()

    init() {
        theme = .Light
    }

    func apply(theme: Theme) {

        self.theme = theme

        // -------------------
        // バックグランド
        // -------------------
        UIView.appearance().backgroundColor = UIColor.clearColor()
        // ナビゲーションバー
        UINavigationBar.appearance().barTintColor = theme.backgroundColor
        // アプリのルートビュー
        RootView.appearance().backgroundColor = theme.backgroundColor
        // コントローラーのルートビュー
        BackgroundView.appearance().backgroundColor = theme.backgroundColor
        // テーブルビュー
        UITableView.appearance().backgroundColor = theme.backgroundColor
        UITableViewCell.appearance().backgroundColor = theme.backgroundColor
        switch theme {
        case .Light:
            let backgroundView = UIView()
            backgroundView.backgroundColor = theme.secondaryColor.colorWithAlphaComponent(0.4)
            UITableViewCell.appearance().selectedBackgroundView = backgroundView
            break
        case .Dark:
            let backgroundView = UIView()
            backgroundView.backgroundColor = theme.secondaryColor.colorWithAlphaComponent(0.4)
            UITableViewCell.appearance().selectedBackgroundView = backgroundView
        }
        // UISearchBarのUITextField
        UITextField.appearance().backgroundColor = theme.borderColor

        // -------------------
        // ボーダー
        // -------------------
        UITableView.appearance().separatorColor = theme.borderColor

        // -------------------
        // テキスト
        // -------------------
        // ステータスバー
        UIApplication.sharedApplication().statusBarStyle = theme.statusBarStyle
        // ナビゲーションバー
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: theme.textColor, NSFontAttributeName: UIFont(name: Font.name, size: 15.0)!]
        // ツールバー
        UIToolbar.appearance().tintColor = theme.primaryColor
        // テーブルビューセル
        TextLabel.appearance().textColor = theme.textColor
        SubTextLabel.appearance().textColor = theme.textColor.colorWithAlphaComponent(0.7)
        UITextField.appearance().defaultTextAttributes = [NSForegroundColorAttributeName: theme.textColor, NSFontAttributeName: UIFont(name: Font.name, size: 15.0)!]


        // -------------------
        // UIToolbar
        // -------------------
        UIToolbar.appearance().barTintColor = theme.backgroundColor

        // -------------------
        // UISearchBar
        // -------------------
        UISearchBar.appearance().tintColor = theme.primaryColor

        // -------------------
        // UISegmentedControl
        // -------------------
        UISegmentedControl.appearance().tintColor = theme.backgroundColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: Font.name, size: 12.0)!], forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: theme.primaryColor, NSFontAttributeName: UIFont(name: Font.name, size: 12.0)!], forState: .Selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: theme.secondaryColor, NSFontAttributeName: UIFont(name: Font.name, size: 12.0)!], forState: .Normal)

        // -------------------
        // UISlider
        // -------------------
        UISlider.appearance().tintColor = theme.secondaryColor
        let image = UIImage(named: "ic_bar_24px")?.imageWithRenderingMode(.AlwaysTemplate)
        UISlider.appearance().setThumbImage(image, forState: .Normal)

        // -------------------
        // UIButton
        // -------------------
        UINavigationBar.appearance().tintColor = theme.primaryColor
        UIButton.appearance().tintColor = theme.primaryColor
        NavigationButton.appearance().tintColor = theme.borderColor
        PrimaryColorButton.appearance().backgroundColor = theme.primaryColor

        //BackgroundView.appearance().backgroundColor = UIColor.clearColor()
        /*
        // 外観
        let tintColor = theme.tintColor()
        let backgroundColor = theme.backgroundColor()
        let textColor = theme.textColor()
        let selectedTextColor = theme.selectedTextColor()
        let borderColor = theme.borderColor()
        // Status bar

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
        */

    }

}