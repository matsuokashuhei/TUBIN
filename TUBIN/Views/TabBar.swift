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
                    label.backgroundColor = tintColor
                    label.textColor = UIColor.whiteColor()
                } else {
                    label.backgroundColor = UIColor.whiteColor()
                    label.textColor = tintColor
                }
            }
        }
    }

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
        selected = false
    }

    private func configure() {
        frame.size = Tab.size()
        configure(label)
    }

    func configure(item: Item) {
        configure()
        label.text = item.title
        addSubview(label)
        selected = false
    }

    func configure(text: String) {
        configure()
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

    class func size() -> CGSize {
        return CGSize(width: 80.0, height: 44.0)
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

    //let tabSize = CGSize(width: 80, height: 44)

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
        selectTab(selectedTab())
    }

    /*
    override func updateConstraints() {
        super.updateConstraints()
        layoutSubviews()
    }
    */

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
        var tab = sender.view as Tab
        selectTab(tab)
        let index = NSArray(array: tabs).indexOfObject(tab)
        delegate?.tabBar(self, didSelectTabAtIndex: index)
    }

    func selectTab(tab: Tab) {
        for tab in tabs {
            tab.selected = false
        }
        tab.selected = true
        centerTab(tab)
    }

    func centerTab(tab: Tab) {
        logger.debug("")

        func contentOffsetOfTabs(tab: Tab) -> CGPoint {
            let x = Tab.size().width * CGFloat(indexOfTabs(tab)) + Tab.size().width / 2
            return CGPoint(x: x, y: tab.frame.origin.y)
        }

        if scrollView.contentSize.width > frame.width {
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
    }

    func syncContentOffset(containerView: UIScrollView) {
        //let containerViewRelatedOffsetX = (containerView.contentOffset.x + containerView.frame.width) / containerView.contentSize.width
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
        logger.debug("containerViewRelatedOffsetX: \(containerViewRelatedOffsetX), offsetX: \(offsetX), x: \(x)")
        offsetX = x
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }

    func selectTabAtIndex(index: Int) {
        let tab = tabAtIndex(index)
        selectTab(tab)
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

    func selectedTab() -> Tab {
        return tabAtIndex(indexOfSelectedTab())
    }

}
