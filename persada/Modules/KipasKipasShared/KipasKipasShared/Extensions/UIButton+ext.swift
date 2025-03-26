import UIKit
import Combine

public extension UIButton {
    var tapPublisher: some Publisher<Void, Never> {
        return publisher(for: .touchUpInside)
    }
}

