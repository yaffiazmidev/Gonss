import Foundation

public struct RegisterUploadPhotoParam: Encodable {
    public let imageData: Data
    
    public init(imageData: Data) {
        self.imageData = imageData
    }
}
