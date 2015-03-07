//
//  SeekBar.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/29.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScrubberViewDelegate {
    func beginSeek(slider: UISlider)
    func seekPositionChanged(slider: UISlider)
    func endSeek(slider: UISlider)
}

class ScrubberView: UIView {
    
    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.addTarget(self, action: "beginSeek:", forControlEvents: .TouchDown)
            slider.addTarget(self, action: "seekPositionChanged:", forControlEvents: .ValueChanged)
            slider.addTarget(self, action: "endSeek:", forControlEvents: (.TouchUpInside | .TouchUpOutside | .TouchCancel))
        }
    }
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

    var delegate: ScrubberViewDelegate?

    func configure() {
        slider.value = 0
        slider.minimumValue = 0
        slider.maximumValue = 0
        startTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.minimumValue), Int32(NSEC_PER_SEC)))
        endTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.maximumValue), Int32(NSEC_PER_SEC)))
    }

    func configure(duration: CMTime) {
        slider.value = 0
        slider.minimumValue = 0
        var maximumValue = Float(CMTimeGetSeconds(duration))
        if maximumValue.isNaN {
            maximumValue = 0
        }
        slider.maximumValue = maximumValue
        startTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.minimumValue), Int32(NSEC_PER_SEC)))
        endTimeLabel.text = formatTime(CMTimeMakeWithSeconds(Float64(slider.maximumValue), Int32(NSEC_PER_SEC)))
    }
    
    func setTime(currentTime: CMTime, duration: CMTime) {
        slider.value = Float(CMTimeGetSeconds(currentTime))
        startTimeLabel.text = formatTime(currentTime)
        let secondsOfEndTime = CMTimeGetSeconds(duration) - CMTimeGetSeconds(currentTime)
        endTimeLabel.text = formatTime(CMTimeMakeWithSeconds(secondsOfEndTime, Int32(NSEC_PER_SEC)))
    }

    func beginSeek(sender: UISlider) {
        delegate?.beginSeek(sender)
    }
    func seekPositionChanged(sender: UISlider) {
        delegate?.seekPositionChanged(sender)
    }
    func endSeek(sender: UISlider) {
        delegate?.endSeek(sender)
    }

    private func formatTime(time: CMTime) -> String {
        let minutes = Int(CMTimeGetSeconds(time) / 60)
        let seconds = Int(CMTimeGetSeconds(time) % 60)
        return NSString(format: "%02ld:%02ld", minutes, seconds)
    }

}