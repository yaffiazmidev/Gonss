import UIKit

public struct CollectionEmptyViewModel {
    let image: UIImage?
    let imageSize: CGSize
    let message: String
    let messageFont: UIFont
    
    public init(
        image: UIImage? = nil,
        imageSize: CGSize = CGSize(width: 72, height: 72),
        message: String,
        messageFont: UIFont = .roboto(.regular, size: 16)
    ) {
        self.image = image
        self.imageSize = imageSize
        self.message = message
        self.messageFont = messageFont
    }
}
