import UIKit

extension UIView {
    /**
     Convert UIView to UIImage
     */
    public func toImage() -> UIImage {
        // Begin graphics context with the view's bounds
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Get the current graphics context
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        // Render the view's layer into the current context
        self.layer.render(in: context)
        
        // Extract the image from the context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}


