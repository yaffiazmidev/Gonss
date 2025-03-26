import Foundation

public class MulticastDelegate<T> {
    
    private class Wrapper {
        weak var delegate: AnyObject?
        
        init(_ delegate: AnyObject) {
            self.delegate = delegate
        }
    }
    
    private var wrappers: [Wrapper] = []
    public var delegates: [T] {
        return wrappers
            .compactMap{ $0.delegate } as! [T]
    }
    
    public func add(delegate: T) {
        let wrapper = Wrapper(delegate as AnyObject)
        if !wrappers.contains(where: { $0 === wrapper }) {
            wrappers.append(wrapper)
        }
    }
    
    public func add(delegates: [T]) {
        delegates.forEach { delegate in
            add(delegate: delegate)
        }
    }
    
    public func remove(delegate: T) {
        guard let index = wrappers.firstIndex(where: {
            $0.delegate === (delegate as AnyObject)
        }) else {
            return
        }
        wrappers.remove(at: index)
    }
    
    public func removeAll() {
        wrappers.removeAll()
    }
    
    public func invokeForEachDelegate(_ handler: (T) -> ()) {
        delegates.forEach { handler($0) }
    }
}
