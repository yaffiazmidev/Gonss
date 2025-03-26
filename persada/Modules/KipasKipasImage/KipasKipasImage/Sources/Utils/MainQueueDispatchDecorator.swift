import Foundation

internal final class MainQueueDispatchDecorator<T> {
  private(set) public var decoratee: T

  internal init(decoratee: T) {
    self.decoratee = decoratee
  }

  internal func dispatch(completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }

    completion()
  }
}
