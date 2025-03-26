//
//  AsynchronousOperation.swift
//  KipasKipas
//
//  Created by Zein Rezky Chandra on 09/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class AsynchronousOperation: Operation {
    
    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }
    
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)
    
    private var rawState: OperationState = .ready
    
    @objc private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
    }
    
    // MARK: - Various `Operation` properties
    
    open         override var isReady:        Bool { return state == .ready && super.isReady }
    public final override var isExecuting:    Bool { return state == .executing }
    public final override var isFinished:     Bool { return state == .finished }
    
    // KVO for dependent properties
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    public final override func start() {
        if isCancelled {
            finish()
            return
        }
        
        state = .executing
        
        main()
    }
    
    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }
    
    public final func finish() {
        if !isFinished { state = .finished }
    }
}
