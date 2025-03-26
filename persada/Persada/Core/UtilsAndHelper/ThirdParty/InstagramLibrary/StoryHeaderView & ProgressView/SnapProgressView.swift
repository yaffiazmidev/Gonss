//
//  SnapProgressView.swift
//  RnDPersada
//
//  Created by NOOR on 13/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ViewAnimator: AnyObject {
		func start(with duration: TimeInterval, width: CGFloat, completion: @escaping (_ storyIdentifier: String, _ snapIndex: Int, _ isCancelledAbruptly: Bool) -> Void)
		func resume()
		func pause()
		func stop()
		func reset()
}

extension ViewAnimator where Self: SnapProgressView {
		func start(with duration: TimeInterval, width: CGFloat, completion: @escaping (_ storyIdentifier: String, _ snapIndex: Int, _ isCancelledAbruptly: Bool) -> Void) {
				UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: {[weak self] in
						if let _self = self {
								_self.frame.size.width = width
						}
				}) { [weak self] (finished) in
						self?.story.isCancelledAbruptly = !finished
						if finished == true {
								if let strongSelf = self {
										return completion(strongSelf.story_identifier!, strongSelf.snapIndex!, strongSelf.story.isCancelledAbruptly)
								}
						} else {
								return completion(self?.story_identifier ?? "Unknowm", self?.snapIndex ?? 0, self?.story.isCancelledAbruptly ?? true)
						}
				}
		}
		func resume() {
				let pausedTime = layer.timeOffset
				layer.speed = 1.0
				layer.timeOffset = 0.0
				layer.beginTime = 0.0
				let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
				layer.beginTime = timeSincePause
		}
		func pause() {
				let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
				layer.speed = 0.0
				layer.timeOffset = pausedTime
		}
		func stop() {
				resume()
				layer.removeAllAnimations()
		}
		func reset() {
				self.story.isCancelledAbruptly = true
				self.frame.size.width = 0
		}
}

final class SnapProgressView: UIView, ViewAnimator {
		public var story_identifier: String?
		public var snapIndex: Int?
//		public var isCancelledAbruptly = false
		public var story: StoriesItem!
}
