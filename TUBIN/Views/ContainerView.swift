//
//  ContainerView.swift
//  Tubin
//
//  Created by matsuosh on 2015/01/05.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

protocol ContainerViewDelegate {
    func containerView(containerView: ContainerView, indexOfContentViews index: Int)
    func containerViewDidScroll(scrollView: UIScrollView)
}

class ContainerView: UIView {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }

    var views: [UIView] = []

    var delegate: ContainerViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        scrollView.contentSize.width = views.reduce(0, combine: { (width: CGFloat, view: UIView) -> CGFloat in
            return width + self.frame.width
        })
        scrollView.contentSize.height = self.bounds.height
        for (index, view) in enumerate(views) {
            view.frame = bounds
            view.frame.origin.x = self.frame.width * CGFloat(index)
        }
    }

    func add(#view: UIView) {
        views.append(view)
        scrollView.addSubview(view)
    }

    func add(#view: UIView, index: Int) {
        views.insert(view, atIndex: index)
        scrollView.addSubview(view)
    }

    func indexOfCurrentView() -> Int {
        return Int(scrollView.contentOffset.x / scrollView.frame.width)
    }

    func scrollToIndexOfContentViews(index: Int) {
        var point = CGPoint(x: 0, y: scrollView.frame.origin.y)
        point.x = scrollView.frame.width * CGFloat(index)
        scrollView.setContentOffset(point, animated: false)
    }

    func clearViews() {
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        views.removeAll(keepCapacity: false)
    }

}

extension ContainerView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = indexOfCurrentView()
        delegate?.containerView(self, indexOfContentViews: index)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.containerViewDidScroll(scrollView)
    }
}