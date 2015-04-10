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
    var selected: Bool! {
        didSet {
            if let selected = selected {
                if selected {
                    UIView.animateWithDuration(0.3) {
                        self.backgroundColor = self.tintColor.colorWithAlphaComponent(1.0)
                        //self.label.textColor = UIColor.whiteColor()
                        self.label.textColor = Appearance.backgroundColor()
                    }
                } else {
                    UIView.animateWithDuration(0.3) {
                        self.backgroundColor = self.tintColor.colorWithAlphaComponent(0.0)
                        self.label.textColor = self.tintColor.colorWithAlphaComponent(1.0)
                    }
                }
            }
        }
    }

    convenience init(item: Item) {
        self.init()
        self.item = item
        configure(item)
    }

    convenience init(text: String) {
        self.init()
        configure(text)
        addSubview(label)
        selected = false
    }

    private func configure() {
        frame.size = Tab.size()
        layer.borderWidth = 0.5
        //layer.borderColor = UIColor.clearColor().CGColor
        layer.borderColor = Appearance.tintColor().CGColor
        __configure(label)
    }

    func configure(item: Item) {
        configure()
        label.text = item.title
        addSubview(label)
        selected = false
    }

    func configure(text: String) {
        configure()
        label.text = NSLocalizedString(text, comment: "")
        /*
        if text == "Favorites" {
            imageView.image = UIImage(named: "ic_favorite_outline_48px")?.imageWithRenderingMode(.AlwaysTemplate)
        } else if text == "Search" {
            imageView.image = UIImage(named: "ic_search_48px")?.imageWithRenderingMode(.AlwaysTemplate)
        } else if text == "Guide" {
            imageView.image = UIImage(named: "ic_map_48px")?.imageWithRenderingMode(.AlwaysTemplate)
        } else if text == "Popular" {
            imageView.image = UIImage(named: "ic_mood_48px")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        imageView.tintColor = Appearance.tintColor()
        imageView.contentMode = .ScaleAspectFit
        imageView.alpha = 0.1
        addSubview(imageView)
        imageView.frame = bounds
        */
        addSubview(label)
    }

    func __configure(label: UILabel) {
        label.frame = self.bounds
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 3
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.font = UIFont(name: Appearance.Font.name, size: 12)
        label.userInteractionEnabled = true
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    class func size() -> CGSize {
        return CGSize(width: 100.0, height: 44.0)
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

    @IBOutlet weak var scrollView: UIScrollView!

    var tabs: [Tab] = []
    var delegate: TabBarDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        // Scroll view
//        scrollView.contentSize.width = tabs.reduce(0, combine: { (width: CGFloat, tab: UILabel) -> CGFloat in
//            return width + tab.frame.size.width
//        })
        scrollView.contentSize.width = Tab.size().width * CGFloat(tabs.count)
        scrollView.contentSize.height = Tab.size().height
        // Tab
        for (index, tab) in enumerate(tabs) {
            tab.frame.size = Tab.size()
            tab.frame.origin.x = tab.frame.size.width * CGFloat(index)
            tab.frame.origin.y = 0
        }
        let indexOfSelectTab = indexOfSelectedTab()
        selectTabAtIndex(indexOfSelectTab)
        delegate?.tabBar(self, didSelectTabAtIndex: indexOfSelectTab)
    }

    func add(#item: Item) {
        let tab = Tab(item: item)
        tab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabTapped:"))
        tabs.append(tab)
        scrollView.addSubview(tab)
    }

    func add(#text: String) {
        let tab = Tab(text: text)
        tab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabTapped:"))
        tabs.append(tab)
        scrollView.addSubview(tab)
    }

    func add(#item: Item, index: Int) {
        let tab = Tab(item: item)
        tab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabTapped:"))
        tabs.insert(tab, atIndex: index)
        scrollView.addSubview(tab)
    }

    func tabTapped(sender: UITapGestureRecognizer) {
        let tab = sender.view as! Tab
        selectTab(tab)
        delegate?.tabBar(self, didSelectTabAtIndex: indexOfTabs(tab))
    }

    /*
    func selectTab(tab: Tab) {
        for tab in tabs {
            tab.selected = false
        }
        tab.selected = true
        centerTab(tab)
    }
    */
    func selectTab(selectedTab: Tab) {
        for tab in tabs {
            if tab == selectedTab {
                continue
            } else {
                tab.selected = false
            }
        }
        selectedTab.selected = true
        centerTab(selectedTab)
    }

    func selectTabAtIndex(index: Int) {
        let tab = tabAtIndex(index)
        selectTab(tab)
    }

    func centerTab(tab: Tab) {
        if scrollView.contentSize.width <= frame.width {
            scrollView.setContentOffset(CGPointZero, animated: true)
            return
        }

        func contentOffsetOfTabs(tab: Tab) -> CGPoint {
            let x = Tab.size().width * CGFloat(indexOfTabs(tab)) + Tab.size().width / 2
            return CGPoint(x: x, y: tab.frame.origin.y)
        }

        var offsetOfTabs = contentOffsetOfTabs(tab)
        let minOffsetX = scrollView.center.x
        let maxOffsetX = scrollView.contentSize.width - (scrollView.frame.width / 2)
        logger.verbose("scrollView.contentSize.width: \(scrollView.contentSize.width)")
        logger.verbose("scrollView.frame.width: \(scrollView.frame.width)")
        logger.verbose("offsetOfTabs.x : \(offsetOfTabs.x), minOffsetX: \(minOffsetX), maxOffsetX: \(maxOffsetX)")
        let x: CGFloat = {
            switch offsetOfTabs.x {
            case let offsetX where offsetX < minOffsetX:
                return 0
            case let offsetX where offsetX > maxOffsetX:
                return self.scrollView.contentSize.width - self.scrollView.frame.width
            default:
                return offsetOfTabs.x - minOffsetX
            }
        }()
        offsetOfTabs.x = x
        logger.verbose("offsetOfTabs.x : \(offsetOfTabs.x)")
        scrollView.setContentOffset(offsetOfTabs, animated: true)
    }

    func syncContentOffset(containerView: UIScrollView) {
        syncSelectedTab(containerView)
        if scrollView.contentSize.width <= frame.width {
            scrollView.setContentOffset(CGPointZero, animated: true)
            return
        }
        let containerViewRelatedOffsetX = containerView.contentOffset.x / containerView.contentSize.width
        var offsetX = scrollView.contentSize.width * containerViewRelatedOffsetX + (Tab.size().width * 0.5)
        let minOffsetX = scrollView.center.x
        let maxOffsetX = scrollView.contentSize.width - (scrollView.frame.width / 2)
        let x: CGFloat = {
            switch offsetX {
            case let offsetX where offsetX < minOffsetX:
                return 0
            case let offsetX where offsetX > maxOffsetX:
                return self.scrollView.contentSize.width - self.scrollView.frame.width
            default:
                return offsetX - minOffsetX
            }
        }()
        logger.verbose("containerViewRelatedOffsetX: \(containerViewRelatedOffsetX), offsetX: \(offsetX), x: \(x)")
        offsetX = x
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }

    func syncSelectedTab(containerView: UIScrollView) {
        let offset = containerView.contentOffset.x / containerView.frame.width
        let left = Int(offset)
        let right = left + 1
        let alpha = offset - CGFloat(left)
        logger.verbose("tabs[\(left)]が\(1 - alpha), tabs[\(left + 1)]が\(alpha)")
        if offset > 0 {
            tabs[left].backgroundColor = tintColor.colorWithAlphaComponent(1 - alpha)
            if alpha > 0.5 {
                tabs[left].label.textColor = tintColor.colorWithAlphaComponent(alpha)
            } else {
                //tabs[left].label.textColor = UIColor.whiteColor().colorWithAlphaComponent(1 - alpha)
                tabs[left].label.textColor = Appearance.backgroundColor().colorWithAlphaComponent(1 - alpha)
            }
            if right < tabs.count {
                tabs[right].backgroundColor = tintColor.colorWithAlphaComponent(alpha)
                if alpha < 0.5 {
                    tabs[right].label.textColor = tintColor.colorWithAlphaComponent(1 - alpha)
                } else {
                    //tabs[right].label.textColor = UIColor.whiteColor().colorWithAlphaComponent(alpha)
                    tabs[right].label.textColor = Appearance.backgroundColor().colorWithAlphaComponent(alpha)
                }
            }
        } else {
            tabs[left].backgroundColor = tintColor.colorWithAlphaComponent(1 + alpha)
            //tabs[left].label.textColor = UIColor.whiteColor().colorWithAlphaComponent(1 + alpha)
            tabs[left].label.textColor = Appearance.backgroundColor().colorWithAlphaComponent(1 + alpha)
        }
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

    func selectedTab() -> Tab {
        return tabAtIndex(indexOfSelectedTab())
    }

    func indexOfTabs(tab: Tab) -> Int {
        return (tabs as NSArray).indexOfObject(tab)
    }

    func indexOfSelectedTab() -> Int {
        for (index, tab) in enumerate(tabs) {
            if let selected = tab.selected {
                if selected {
                    return index
                }
            }
        }
        return 0
    }

    func clearTabs() {
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        tabs.removeAll(keepCapacity: false)
    }

}