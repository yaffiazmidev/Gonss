import UIKit

extension UIImageView {
    public func setImageAnimated(
        _ newImage: UIImage?,
        defaultImage: UIImage? = nil
    ) {
        
        image = newImage ?? defaultImage
    
        guard newImage != nil else { return }
        
        if image == nil {
            alpha = 0.7
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
}

