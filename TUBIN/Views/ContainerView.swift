//
//  ContainerView.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/05.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import XCGLogger

protocol ContainerViewDelegate {
    func containerView(containerView: ContainerView, indexOfContentViews index: Int)
    func containerViewDidScroll(contentOffsetX: CGFloat, contentSizeWidth: CGFloat)
}

class ContainerView: UIView {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }

    var views: [UIView] = []

    var selectedViewAtIndex: Int! {
        /*
        0 | 0 1
        1 | 0 1 2
        2 |   1 2 3
        3 |     2 3 4
        4 |       3 4 5
        5 |         4 5
        */
        didSet(oldIndex) {
            let newIndexes = [selectedViewAtIndex - 1, selectedViewAtIndex, selectedViewAtIndex + 1].filter { (index: Int) -> Bool in
                index > -1 && index < self.views.count
            }
            if let oldIndex = oldIndex {
                let oldIndexes = [oldIndex - 1, oldIndex, oldIndex + 1].filter { (index: Int) -> Bool in
                    index > -1 && index < self.views.count
                }
                logger.debug("oldIndex: \(oldIndex), oldIndexes: \(oldIndexes), selectedViewAtIndex: \(self.selectedViewAtIndex), newIndexes: \(newIndexes)")
                if oldIndex < selectedViewAtIndex {
                    for oldIndex in oldIndexes {
                        if contains(newIndexes, oldIndex) == false {
                            if let view = scrollView.subviews.first as? UIView {
                                logger.debug("\(oldIndex)を消す。")
                                view.removeFromSuperview()
                            }
                        }
                    }
                    for newIndex in newIndexes {
                        if contains(oldIndexes, newIndex) == false {
                            logger.debug("\(newIndex)を足す。")
                            scrollView.addSubview(views[newIndex])
                        }
                    }
                }
                if oldIndex > selectedViewAtIndex {
                    for oldIndex in reverse(oldIndexes) {
                        if contains(newIndexes, oldIndex) == false {
                            if let view = scrollView.subviews.last as? UIView {
                                logger.debug("\(oldIndex)を消す。")
                                view.removeFromSuperview()
                            }
                        }
                    }
                    for newIndex in reverse(newIndexes) {
                        if contains(oldIndexes, newIndex) == false {
                            logger.debug("\(newIndex)を足す。")
                            scrollView.insertSubview(views[newIndex], atIndex: 0)
                        }
                    }
                }
            } else {
                for newIndex in newIndexes {
                    logger.debug("\(newIndex)を足す。")
                    scrollView.addSubview(views[newIndex])
                }
            }
            scrollView.contentSize.width = CGFloat(scrollView.subviews.count) * frame.width
            for (index, subview) in enumerate(scrollView.subviews) {
                if let subview = subview as? UIView {
                    subview.frame = bounds
                    subview.frame.origin.x = frame.width * CGFloat(index)
                }
            }
        }
    }

    var delegate: ContainerViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        scrollView.contentSize = {
            let width = CGFloat(self.scrollView.subviews.count) * self.frame.width
            let height = self.frame.height
            return CGSize(width: width, height: height)
        }()
        for (index, subview) in enumerate(scrollView.subviews) {
            if let subview = subview as? UIView {
                subview.frame = bounds
                subview.frame.origin.x = frame.width * CGFloat(index)
            }
        }
        /*
        scrollView.frame = self.bounds
        scrollView.contentSize.width = views.reduce(0, combine: { (width: CGFloat, view: UIView) -> CGFloat in
            return width + self.frame.width
        })
        scrollView.contentSize.height = self.bounds.height
        for (index, view) in enumerate(views) {
            view.frame = bounds
            view.frame.origin.x = self.frame.width * CGFloat(index)
        }
        */
    }

    func add(#view: UIView) {
        views.append(view)
        //scrollView.addSubview(view)
    }

    func add(#view: UIView, index: Int) {
        views.insert(view, atIndex: index)
        //scrollView.addSubview(view)
    }

    func selectViewAtIndex(index: Int) {
        selectedViewAtIndex = index
        if let subviews = scrollView.subviews as? [UIView] {
            let index = (subviews as NSArray).indexOfObject(views[index])
            let point = CGPoint(x: frame.width * CGFloat(index), y: 0)
            logger.debug("index: \(index), point: \(point)")
            scrollView.setContentOffset(point, animated: false)
        }
        /*
        let point = CGPoint(x: frame.width * CGFloat(index), y: 0)
        logger.debug("index: \(index), point: \(point)")
        scrollView.setContentOffset(point, animated: false)
        */
    }

    func indexOfCurrentView() -> Int {
        let indexOfScrollView = Int(scrollView.contentOffset.x / scrollView.frame.width)
        logger.debug("indexOfScrollView: \(indexOfScrollView)")
        if let scrollView = scrollView {
            logger.debug("scrollView: \(scrollView)")
            if let subviews = scrollView.subviews as? [UIView] {
                logger.debug("subviews.count: \(subviews.count)")
            }
        }
        if let subview = scrollView.subviews[indexOfScrollView] as? UIView {
            return (views as NSArray).indexOfObject(subview)
        }
        return 0
    }

    /*
    func scrollToIndexOfContentViews(index: Int) {
        selectViewAtIndex(index)
        /*
        var point = CGPoint(x: 0, y: scrollView.frame.origin.y)
        point.x = scrollView.frame.width * CGFloat(index)
        scrollView.setContentOffset(point, animated: false)
        */
    }
    */

    func clearViews() {
        scrollView.contentOffset.x = 0
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        views.removeAll(keepCapacity: false)
    }

}

extension ContainerView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        logger.debug("contentOffset.x: \(scrollView.contentOffset.x)")
        let index = indexOfCurrentView()
        logger.debug("index: \(index)")
        selectViewAtIndex(index)
        delegate?.containerView(self, indexOfContentViews: index)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        logger.debug("contentOffset.x: \(scrollView.contentOffset.x)")
        // 現在のタブの番号
        let index = indexOfCurrentView()
        // ----------------------------
        // スクロールビューの位置情報を作る。
        // ----------------------------
        // 幅
        let width = frame.width * CGFloat(views.count)
        let x: CGFloat = {
            if self.selectedViewAtIndex == 0 {
                return scrollView.contentOffset.x
            } else if self.selectedViewAtIndex == index {
                return scrollView.contentOffset.x + self.frame.width * CGFloat(self.selectedViewAtIndex - 1)
            } else if self.selectedViewAtIndex > index {
                return scrollView.contentOffset.x + self.frame.width * CGFloat(index)
            } else {
                return 0.0
            }
        }()
        logger.debug("selectedViewAtIndex: \(self.selectedViewAtIndex), index: \(index), x: \(x), width: \(width), scrollView: contentOffset.x: \(scrollView.contentOffset.x), contentSize.width: \(scrollView.contentSize.width)")
        //if x < frame.width + frame.width * CGFloat(selectedViewAtIndex) {
        if index <= selectedViewAtIndex {
            delegate?.containerViewDidScroll(x, contentSizeWidth: width)
        }
        /*
        logger.debug("contentOffsetX: \(self.scrollView.contentOffset.x + self.frame.width * CGFloat(index)), contentSize: \(self.frame.width * CGFloat(self.views.count))")
        if scrollView.contentOffset.x < frame.width {
            delegate?.containerViewDidScroll(scrollView.contentOffset.x + frame.width * CGFloat(index), contentSizeWidth: frame.width * CGFloat(views.count))
        }
        */
    }
}