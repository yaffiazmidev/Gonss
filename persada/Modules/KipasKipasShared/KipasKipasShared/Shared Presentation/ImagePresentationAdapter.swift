import UIKit

public typealias ImageResourceLoader = AnyResourceLoader<URL, [String: Data]>

public typealias ImagePresentationAdapter<View: ResourceView> = LoadResourcePresentationAdapter<ImageResourceLoader, View> where View.ResourceViewModel == [String: UIImage]

public extension UIImage {
    static func tryMake(dict: [String: Data]) throws -> [String: UIImage] {
        return dict.mapToValidUIImageDictionary()
    }
}

private extension Dictionary where Key == String, Value == Data {
    func mapToValidUIImageDictionary() -> [String: UIImage] {
        let imageDictionary = self.mapValues { UIImage(data: $0) }
        return imageDictionary.compactMapValues { $0 }
    }
}
