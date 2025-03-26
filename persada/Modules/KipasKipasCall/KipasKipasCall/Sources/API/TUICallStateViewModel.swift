//
//  TUICallStateViewModel.swift
//  KipasKipasCall
//
//  Created by MissYasiky on 2024/2/4.
//

import Foundation
import Combine

public enum KipasKipasCallState: Int {
    case notOnCall // default, not on call
    case calling // call others
    case waiting // receive other‘s calling
    case onCall // take a call with other
}

public class TUICallStateViewModel: NSObject {
    public static let shared = TUICallStateViewModel()
    
    @Published public var isLiving: Bool = false
    
    private var pState: KipasKipasCallState = .notOnCall
    
    public var state: KipasKipasCallState {
        get {
            return pState
        }
    }
    
    func updateState(_ state: KipasKipasCallState) {
        let originState = self.pState
        self.pState = state
        if originState != state {
            NotificationCenter.default.post(name: .init("callStateChanged"), object: nil, userInfo: ["state": self.pState.rawValue])
        }
    }
}
