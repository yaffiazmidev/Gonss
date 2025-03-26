//
//  CountdownManager.swift
//  FeedCleeps
//
//  Created by DENAZMI on 19/01/23.
//

import Foundation

public protocol ICountdownManager {
    var didChangeCountdown: ((Int) ->Void)? { get set }
    var didFinishCountdown: (() ->Void)? { get set }
    
    func startTimer(timeLeft: Int)
    func stopTimer()
    func setupObserver()
    func removeObserver()
}

public class CountdownManager: ICountdownManager {
    
    private let notificationCenter: NotificationCenter
    private let willResignActive: NSNotification.Name
    private let willEnterForeground: NSNotification.Name
    
    private var timeLeft: Int = 0
    private var latestTime: String?
    private var timer: Timer = {
        let timer = Timer()
        return timer
    }()
    
    
    public var didChangeCountdown: ((Int) ->Void)?
    public var didFinishCountdown: (() ->Void)?
    
    public init(notificationCenter: NotificationCenter, willResignActive: NSNotification.Name, willEnterForeground: NSNotification.Name) {
        self.notificationCenter = notificationCenter
        self.willResignActive = willResignActive
        self.willEnterForeground = willEnterForeground
    }
    
    public func setupObserver() {
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: willResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: willEnterForeground, object: nil)
    }
    
    public func removeObserver() {
        notificationCenter.removeObserver(self, name: willResignActive, object: nil)
        notificationCenter.removeObserver(self, name: willEnterForeground, object: nil)
    }
    
    public func startTimer(timeLeft: Int) {
        self.timeLeft = timeLeft
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(countdownTick),
            userInfo: nil,
            repeats: true
        )
        timer.fire()
    }

    @objc private func appMovedToForeground() {
        if let latestTime = latestTime, let newDateStr = dateToString(date: Date()) {
            if let latest = stringToDate(date: latestTime), let new = stringToDate(date: newDateStr) {
                let intervalTime = Int(new.timeIntervalSince(latest))
                timeLeft -= intervalTime
            }
        }
    }

    @objc private func appMovedToBackground() {
        latestTime = dateToString(date: Date())
    }

    public func stopTimer() {
        timeLeft = 0
        latestTime = nil
        timer.invalidate()
        removeObserver()
    }

    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @objc private func countdownTick() {
        timeLeft -= 1
        
        didChangeCountdown?(timeLeft)
        print(timeFormatted(timeLeft))
        
        guard timeLeft <= 0 else {
            return
        }
        stopTimer()
        didFinishCountdown?()
    }
    
    private func dateToString(date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    private func stringToDate(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.date(from: date)
    }
}
