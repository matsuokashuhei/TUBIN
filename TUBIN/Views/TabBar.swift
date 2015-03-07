//
//  TabBar.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/05.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
//import QuartzCore
import YouTubeKit

protocol TabBarDelegate {
    func tabBar(tabBar: TabBar, didSelectTabAtIndex index: Int)
}

class Tab: UIView {

    var item: Item?
    var label = UILabel()
    var imageView = UIImageView()

    init(item: Item) {
        self.item = item
        super.init()
        configure(item)
        /*
        item.thumbnailImage { (image, error) -> Void in
            if let image = image {
                self.imageView = UIImageView(image: image)
                self.addSubview(self.imageView!)
                self.imageView?.frame = CGRect(x: 0, y: 1, width: 42, height: 28)
            }
        }
        */
    }

    init(text: String) {
        super.init()
        configure(text)
        addSubview(label)
    }

    func configure(item: Item) {
        frame.size = CGSize(width: 80.0, height: 44.0)
        configure(label)
        label.text = item.title
        addSubview(label)
    }

    func configure(text: String) {
        frame.size = CGSize(width: 80.0, height: 44.0)
        configure(label)
        label.text =  text
        addSubview(label)
    }

    func configure(label: UILabel) {
        label.frame = self.bounds
        label.layer.borderWidth = 0.5
        //tab.layer.borderColor = UIColor.grayColor().CGColor
        label.layer.borderColor = tintColor.CGColor
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 3
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.font = UIFont(name: "Avenir Next", size: 10)
        label.textColor = tintColor
        label.userInteractionEnabled = true
        //label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapTab:"))
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

class TabBar: UIView {

    /*
    黒魔術AutoLayoutとiPhone 6/6 Plus
    https://speakerdeck.com/shoby/6-plus

    UIScrollView And Autolayout
    https://developer.apple.com/library/ios/technotes/tn2154/_index.html
    
    Using UIScrollView with Auto Layout in iOS
    http://spin.atomicobject.com/2014/03/05/uiscrollview-autolayout-ios/

    */
    let logger = XCGLogger.defaultInstance()

    let tabSize = CGSize(width: 80, height: 44)
    //let tabSize = CGSize(width: 58, height: 44)

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }

    //var tabs: [UILabel] = []
    var tabs: [Tab] = []
    var delegate: TabBarDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        // Scroll view
//        scrollView.contentSize.width = tabs.reduce(0, combine: { (width: CGFloat, tab: UILabel) -> CGFloat in
//            return width + tab.frame.size.width
//        })
        scrollView.contentSize.width = tabSize.width * CGFloat(tabs.count)
        scrollView.contentSize.height = tabSize.height
        // Tab
        for (index, tab) in enumerate(tabs) {
            tab.frame.size = tabSize
            tab.frame.origin.x = tab.frame.size.width * CGFloat(index)
            tab.frame.origin.y = 0
        }
    }

    /*
    override func updateConstraints() {
        super.updateConstraints()
        layoutSubviews()
    }
    */

    func add(#item: Item) {
        let tab = Tab(item: item)
        tab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapTab:"))
        tabs.append(tab)
        scrollView.addSubview(tab)
    }

    func add(#text: String) {
        let tab = Tab(text: text)
        tab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapTab:"))
        tabs.append(tab)
        scrollView.addSubview(tab)
    }

    func add(#item: Item, index: Int) {
        let tab = Tab(item: item)
        tab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapTab:"))
        tabs.insert(tab, atIndex: index)
        scrollView.addSubview(tab)
    }

    func tapTab(sender: UITapGestureRecognizer) {
        var tab = sender.view as Tab
        centerTab(tab)
        let index = NSArray(array: tabs).indexOfObject(tab)
        delegate?.tabBar(self, didSelectTabAtIndex: index)
    }

    func centerTab(tab: Tab) {
        logger.verbose("tab.center.x: \(tab.center.x), scrollView.center.x: \(scrollView.center.x), scrollView.contentSize.width: \(scrollView.contentSize.width)")
        var point = CGPoint(x: 0, y: tab.frame.origin.y)
        if scrollView.contentSize.width >= frame.width {
            switch tab.center.x {
            case 0..<scrollView.center.x:
                // タップしたタブが左
                point.x = 0
            case scrollView.center.x..<(scrollView.contentSize.width - scrollView.center.x):
                // タップしたタブが真ん中
                point.x = tab.center.x - scrollView.center.x
            case (scrollView.contentSize.width - scrollView.center.x)..<scrollView.contentSize.width:
                // タップしたタブが右
                point.x = scrollView.contentSize.width - scrollView.frame.width
            default:
                break
            }
        }
        selectTab(tab)
        scrollView.setContentOffset(point, animated: true)
    }

    func centerTabAtIndex(index: Int) {
        let tab = tabAtIndex(index)
        centerTab(tab)
        //centerTab(tabAtIndex(index))
    }

    func clearTabs() {
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        tabs.removeAll(keepCapacity: false)
    }

    func tabAtIndex(index: Int) -> Tab {
        if index < 0 {
            return tabs.first!
        }
        if index < tabs.count {
            return tabs[index]
        }
        return tabs.last!
    }

    func selectTab(tab: Tab) {
        for tab in tabs {
            tab.label.backgroundColor = UIColor.whiteColor()
            tab.label.textColor = tintColor
        }
        tab.label.backgroundColor = tintColor
        tab.label.textColor = UIColor.whiteColor()
    }
}

extension TabBar: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
}