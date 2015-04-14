//
//  Appearance.swift
//  TUBIN
//
//  Created by matsuosh on 2015/03/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

class Appearance {

    struct Font {
        static let name = "AvenirNext-Regular"
    }

    class func apply(theme: Theme) {
        sharedInstance.apply(theme)
    }

    enum Theme {

        case Light
        case Dark

        var primaryColor: UIColor {
            return UIColor(hexString: "FC115D")!
        }

        var secondaryColor: UIColor {
            return UIColor(hexString: "524065")!
        }

        var darkColor: UIColor {
            //return UIColor(hexString: "050113")!
            return UIColor(red: 9.0/255.0, green: 3.0/255.0, blue: 26.0/255.0, alpha: 1.0)
        }

        var lightColor: UIColor {
            return UIColor(hexString: "FFFFFF")!
        }

        var backgroundColor: UIColor {
            switch self {
            case .Light:
                return lightColor
            case .Dark:
                return darkColor
            }
        }

        var selectedTab: (textColor: UIColor, backgroundColor: UIColor) {
            return (textColor: primaryColor, backgroundColor: secondaryColor.colorWithAlphaComponent(0.4))
        }

        var tab: (textColor: UIColor, backgroundColor: UIColor) {
            return (textColor: secondaryColor, backgroundColor: backgroundColor)
        }

        var selectedTabTextColor: UIColor {
            return primaryColor
        }

        var tabTextColor: UIColor {
            return secondaryColor
        }

        var borderColor: UIColor {
            switch self {
            case .Light:
                return UIColor.lightGrayColor()
            case .Dark:
                return UIColor.darkGrayColor()
            }
        }

        var textColor: UIColor {
            switch self {
            case .Light:
                return darkColor
            case .Dark:
                return lightColor
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
        // UINavigationBar
        UINavigationBar.appearance().barTintColor = theme.backgroundColor
        // アプリのルートビュー
        RootView.appearance().backgroundColor = theme.backgroundColor
        // コントローラーのルートビュー
        BackgroundView.appearance().backgroundColor = theme.backgroundColor
        // UITableView
        UITableView.appearance().backgroundColor = theme.backgroundColor
        UITableViewCell.appearance().backgroundColor = theme.backgroundColor
        switch theme {
        case .Light:
            let backgroundView = UIView()
            backgroundView.backgroundColor = theme.secondaryColor.colorWithAlphaComponent(0.3)
            UITableViewCell.appearance().selectedBackgroundView = backgroundView
            break
        case .Dark:
            let backgroundView = UIView()
            backgroundView.backgroundColor = theme.secondaryColor.colorWithAlphaComponent(0.3)
            UITableViewCell.appearance().selectedBackgroundView = backgroundView
        }
        // UISearchBar
        switch theme {
        case .Light:
            UISearchBar.appearance().searchBarStyle = .Minimal
        case .Dark:
            UISearchBar.appearance().searchBarStyle = .Default
        }
        UISearchBar.appearance().barTintColor = theme.backgroundColor
        UISearchBar.appearance().translucent = true
        // UILabel
        DarkLabel.appearance().textColor = theme.lightColor
        DarkLabel.appearance().backgroundColor = theme.darkColor.colorWithAlphaComponent(0.8)

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
        SubTextLabel.appearance().textColor = theme.textColor.colorWithAlphaComponent(0.6)
        switch theme {
        case .Light:
            UITextField.appearance().defaultTextAttributes = [NSForegroundColorAttributeName: theme.textColor, NSFontAttributeName: UIFont(name: Font.name, size: 14.0)!]
        case .Dark:
            UITextField.appearance().defaultTextAttributes = [NSForegroundColorAttributeName: theme.backgroundColor, NSFontAttributeName: UIFont(name: Font.name, size: 14.0)!]
        }


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
        UISegmentedControl.appearance().tintColor = theme.secondaryColor.colorWithAlphaComponent(0.4)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: theme.primaryColor, NSFontAttributeName: UIFont(name: Font.name, size: 14.0)!], forState: .Selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: theme.secondaryColor, NSFontAttributeName: UIFont(name: Font.name, size: 14.0)!], forState: .Normal)

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

        // UISwitch
        UISwitch.appearance().onTintColor = theme.secondaryColor
        UISwitch.appearance().thumbTintColor = theme.primaryColor
    }

}