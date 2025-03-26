//
//  FeedCallStateManager.swift
//  FeedCleeps
//
//  Created by MissYasiky on 2024/2/4.
//

import Foundation

enum FeedCallState: Int {
    case notOnCall // default, not on call
    case calling // call others
    case waiting // receive other‘s calling
    case onCall // take a call with other
}

class FeedCallStateManager: NSObject {
    static let shared = FeedCallStateManager()
    var state: FeedCallState = .notOnCall
    
    private override init() {
        super.init()
        self.bindCallObserver()
    }
    
    private func bindCallObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onCallStart), name: .init("callStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCallReceived), name: .init("callReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCallCancelle), name: .init("callCancelled"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCallBegin), name: .init("callBegin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCallEnd), name: .init("callEnd"), object: nil)
    }
    
    @objc func onCallStart() {
        state = .calling
    }
    
    @objc func onCallReceived() {
        state = .waiting
    }
    
    @objc func onCallCancelle() {
        state = .notOnCall
    }
    
    @objc func onCallBegin() {
        state = .onCall
    }
    
    @objc func onCallEnd() {
        state = .notOnCall
    }
}
