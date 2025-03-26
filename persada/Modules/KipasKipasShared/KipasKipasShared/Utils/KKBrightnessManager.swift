//
//  KKBrightnessManager.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/06/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

public class KKBrightnessManager {
    public static let shared: KKBrightnessManager = KKBrightnessManager()
    private var isAppear: Bool
    private let LOG_ID = "***KKBrightnessManager"
    public var lastBrightness: CGFloat = -1
    private var onUpdateBrightness: Bool = false
    private var timer: Timer?
    private var lastChanged: Date = Date()
    
    // Set constructor/initializers private, another class can't create this class
    private init() {
        self.isAppear = true
    }
    
    /// This function for configuring the Brightness Manager,  just call this function once
    public func configure() {
        self.adjustBrightness(){
            self.createBrightnessObserver()
        }
        self.createBackgroundObserver()
    }
    
    private func updateBrightness(_ to: CGFloat, animationDuration: CGFloat = 1, completion: (() -> Void)? = nil ){
        self.onUpdateBrightness = true
        print(LOG_ID, "Change the brightness to", to)
        UIScreen.main.adjustScreenBrightness(to: to) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print(self.LOG_ID, "brightness has been set to", to)
                self.lastBrightness = to
                self.onUpdateBrightness = false
                completion?()
            }
        }
    }
}

// MARK: - For handle observer
fileprivate extension KKBrightnessManager {
    private func createBrightnessObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(brightnessDidChange), name: UIScreen.brightnessDidChangeNotification, object: nil)
    }
    
    @objc func brightnessDidChange() {
        let minBrightness = 0.5
        let brightness = UIScreen.main.brightness
        self.lastChanged = Date()
        
        if !self.isAppear { // User manually setup brightness
            self.lastBrightness = brightness
            print(LOG_ID, "User adjusts brightness manually to", self.lastBrightness)
            return
        }
        
        print(LOG_ID, "OS change brightness to", brightness)
        if self.lastBrightness == brightness { // if the values are the same, then nothing will be done
            print(LOG_ID, "The previous brightness value is the same as the current brightness value", self.lastBrightness)
            return
        }

        if timer == nil && !onUpdateBrightness {
            createTimer()
        }
    }
    
    private func createTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            if (self.lastChanged.timeIntervalSinceNow * -1) > 4 {
                print(self.LOG_ID, "timer running", self.lastChanged.timeIntervalSinceNow * -1)
                self.adjustBrightness(){
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        })
    }
    
    private func adjustBrightness(function: String = #function, completion: (() -> Void)? = nil) {
        let minBrightness = 0.5
        let brightness = UIScreen.main.brightness
        
        guard !onUpdateBrightness else {
            print(LOG_ID, "ignoring adjust brightness from", brightness, "because on update progress. Called from", function)
            completion?()
            return
        }
        
        if brightness < minBrightness {
            let n = min(brightness + 0.05, 1.0)
            print(LOG_ID, "adjust brightness from", brightness, "to", n, ". Called from", function)
            self.updateBrightness(n, completion: completion)
            return
        }
        completion?()
        print(LOG_ID, "ignoring adjust brightness from", brightness, ". Called from", function)
    }
    
    private func createForegroundObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func createBackgroundObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    @objc private func willResignActive(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: UIScene.willDeactivateNotification, object: nil)
        self.createForegroundObserver()
        self.isAppear = false
    }
    
    @objc private func willEnterForeground(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        self.createBackgroundObserver()
        self.isAppear = true
    }
}


fileprivate extension UIScreen {
    // MARK: - For animating brightness
    func adjustScreenBrightness(to value: CGFloat, animationDuration: CGFloat = 1, completion: (() -> Void)? = nil) {
        var currentBrightness: CGFloat = UIScreen.main.brightness
        
        // MARK: 1) Determine the direction of the adjustment; Increase / Decrease
        let isIncreasing: Bool = currentBrightness < value
        
        // MARK: 2) Determine the animation speed
        let incrementalStep: CGFloat = 1 / (animationDuration * 1000)
        
        // MARK: 3) Execute the iteration operation in a separate thread
        DispatchQueue.global(qos: .userInteractive).async {
            while (isIncreasing && currentBrightness <= value) || (!isIncreasing && currentBrightness >= value) {
                DispatchQueue.main.async {
                    currentBrightness += isIncreasing ? incrementalStep : -incrementalStep
                    UIScreen.main.brightness = currentBrightness
                }
                
                // MARK: 4) Set 1 milisecond interval to the while-loop
                Thread.sleep(forTimeInterval: 1 / 1000)
            }
            completion?()
        }
    }
}
