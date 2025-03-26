import UIKit
import Combine

public final class KeyboardHandler {

    private let keyboardNotifications: [NSNotification.Name] = [
        UIResponder.keyboardWillShowNotification,
        UIResponder.keyboardDidShowNotification,
        UIResponder.keyboardWillHideNotification,
        UIResponder.keyboardDidHideNotification
    ]
    
    private(set) var currentState: KeyboardState?
    private var cancellable: AnyCancellable?
    
    private let onChange:((KeyboardState) -> Void)

    public init(with changeHandler: @escaping ((KeyboardState) -> Void)) {
        self.onChange = changeHandler
            
        cancellable = Publishers.MergeMany(
            keyboardNotifications.map { NotificationCenter.default.publisher(for: $0) }
        )
        .sink(receiveValue: { [weak self] (note) in
            guard let self = self else { return }
            
            currentState = KeyboardState(with: note)
            onChange(KeyboardState(with: note))
        })
    }
    
    public func unsubscribe() {
        cancellable?.cancel()
    }
    
    @objc private func receivedKeyboardNotification(notification: Notification) {
        currentState = KeyboardState(with: notification)
        onChange(KeyboardState(with: notification))
    }
}
