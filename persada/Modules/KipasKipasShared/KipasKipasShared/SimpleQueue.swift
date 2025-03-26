import Foundation
import Combine

public final class SimpleQueue<T> {
    
    public var queues: [T] = []
    private var currentQueue: Int = 0
    
    private let maxQueue: Int
    private let completion: (T?) -> Void
    
    public init(
        maxQueue: Int,
        completion: @escaping (T?) -> Void
    ) {
        self.maxQueue = maxQueue
        self.completion = completion
    }
    
    public func enqueue(_ queue: T) {
        if currentQueue < maxQueue {
            currentQueue += 1
            
            var last = queues.last
            
            if let last {
                queues.removeLast()
                queues.append(last)
            } else {
                queues.append(queue)
                last = queue
            }
            
            completion(last)
            
        } else {
            queues.append(queue)
        }
    }
    
    public func dequeue() {
        if let last  = queues.last {
            queues.removeLast()
            completion(last)
            
        } else {
            currentQueue -= 1
            currentQueue = max(0, currentQueue)
        }
    }
}
