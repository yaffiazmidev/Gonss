import Foundation
import UIKit
import SwiftUI

extension UIViewController {
    // enable preview for UIKit
    // source: https://dev.to/gualtierofr/preview-uikit-views-in-xcode-3543
    @available(iOS 13, *)
    private struct Preview: UIViewControllerRepresentable {
        
        typealias UIViewControllerType = UIViewController
        let controller: UIViewController
        func makeUIViewController(context: Context) -> UIViewController {
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    @available(iOS 13, *)
    public func showPreview() -> some View {
        // inject self (the current UIView) for the preview
        Preview(controller: self)
    }
}
