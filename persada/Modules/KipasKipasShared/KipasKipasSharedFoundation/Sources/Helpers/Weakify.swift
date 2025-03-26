import Foundation

/// (T) -> (U) -> ()
public func weakify<T: AnyObject, U>(_ owner: T, _ f: @escaping (T) -> (U) -> Void) -> (U) -> Void {
    return { [weak owner] obj in
        guard let owner = owner else { return }
        f(owner)(obj)
    }
}

/// (T) -> () -> ()
public func weakify<T: AnyObject>(_ owner: T, _ f: @escaping (T) -> () -> Void) -> () -> Void {
    return { [weak owner] in
        guard let owner = owner else { return }
        f(owner)()
    }
}
