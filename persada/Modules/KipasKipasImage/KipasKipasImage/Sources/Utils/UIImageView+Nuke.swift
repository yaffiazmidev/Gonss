import Nuke
import UIKit

public let pipeline = ImagePipeline { config in
    config.isProgressiveDecodingEnabled = true
    config.imageCache = ImageCache()
    config.dataCache = try? DataCache(name: "com.koanba.KipasKipasImage.cache")
}

public let imagePrefetcher = ImagePrefetcher(
    pipeline: pipeline,
    maxConcurrentRequestCount: 10
)

public enum ImageSize: String {
    case w_24
    case w_36
    case w_40
    case w_50
    case w_100
    case w_200
    case w_300
}

public struct ImageLoaderRequest {
    public let url: URL?
    public let size: ImageSize?
    
    public init(
        url: URL?,
        size: ImageSize? = nil) {
        self.url = url
        self.size = size
    }
    
    var resizeURL: URL? {
        guard let url = url else { return nil }

        if let size = size {
            let resizeQuery = "?x-oss-process=image/format,jpg/interlace,1/resize,\(size.rawValue)"
            let enrichedString = url.absoluteString.appending(resizeQuery)
            return URL(string: enrichedString)
        } else {
            return url
        }
    }
}

@MainActor public func fetchImage(
    with request: ImageLoaderRequest,
    into displayableView: ImageDisplayingView,
    defaultImage: UIImage? = nil,
    isTransitioning: Bool = false,
    completion: @escaping (UIImage?, Error?) -> Void = { _,_  in }
) {
    var options = ImageLoadingOptions()
    options.pipeline = pipeline
    
    if isTransitioning {
        options.transition = .fadeIn(duration: 0.25)
    }
    
    options.isPrepareForReuseEnabled = false

    loadImage(
        with: request.resizeURL,
        options: options,
        into: displayableView) { result in
            switch result {
            case let .success(response):
                completion(response.image, nil)
            case let .failure(error):
                if let image = defaultImage {
                    displayableView.nuke_display(image: image, data: nil)
                }
                completion(nil, error)
            }
        }
}
