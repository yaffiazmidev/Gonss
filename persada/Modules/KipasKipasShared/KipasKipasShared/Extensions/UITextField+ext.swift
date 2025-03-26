import UIKit
import Combine

public extension UITextField {
    func validationPublisher(with validator: any Validator) -> some Publisher<ValidationResult, Never> {
        publisher(for: .editingChanged)
            .map { _ in validator.validate(self.text ?? "") }
    }
    
    var editingChangedPublisher: some Publisher<String, Never> {
        publisher(for: .editingChanged)
            .compactMap { _ in self.text }
    }
    
    var endEditingPublisher: some Publisher<String, Never> {
        publisher(for: .editingDidEnd)
            .compactMap { _ in self.text }
    }
}
