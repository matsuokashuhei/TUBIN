//
//  SeekBar.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/29.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

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

    func configure(duration: Double) {
        logger.debug("duration: \(duration)")
        configure(CMTimeMake(Int64(duration), 1))
    }

    func sync(controller: MPMoviePlayerController) {
        configure(controller.duration)
        setTime(controller.currentPlaybackTime, duration: controller.duration)
    }

    func setTime(currentTime: CMTime, duration: CMTime) {
        slider.value = Float(CMTimeGetSeconds(currentTime))
        startTimeLabel.text = formatTime(currentTime)
        let secondsOfEndTime = CMTimeGetSeconds(duration) - CMTimeGetSeconds(currentTime)
        endTimeLabel.text = formatTime(CMTimeMakeWithSeconds(secondsOfEndTime, Int32(NSEC_PER_SEC)))
    }

    func setTime(currentTime: Double, duration: Double) {
        setTime(CMTimeMake(Int64(currentTime), 1), duration: CMTimeMake(Int64(duration), 1))
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
        let _time = CMTimeGetSeconds(time)
        let hours = Int(_time / 3600)
        if hours > 0 {
            let minutes = Int((_time / 60) % 60)
            let seconds = Int(_time % 60)
            return NSString(format: "%d:%02ld:%02ld", hours, minutes, seconds)
        } else {
            let minutes = Int(_time / 60)
            let seconds = Int(_time % 60)
            return NSString(format: "%02ld:%02ld", minutes, seconds)
        }
    }

}