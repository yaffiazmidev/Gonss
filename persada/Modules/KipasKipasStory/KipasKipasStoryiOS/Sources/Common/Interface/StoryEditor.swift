import UIKit
import KipasKipasShared

public protocol StoryEditorPresentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: StoryEditorPresentable {
    public func toPresentable() -> UIViewController {
        return self
    }
}

public protocol StoryEditor: StoryEditorPresentable {
    func switchToTextEditingMode(editingTextView textView: UITextView?)
    func saveMedia()
    func exportMedia(with completion: @escaping (KKMediaItem) -> Void)
}

public protocol StoryEditorDelegate: AnyObject {
    func didEnterEditingMode()
    func didExitEditingMode()
}
