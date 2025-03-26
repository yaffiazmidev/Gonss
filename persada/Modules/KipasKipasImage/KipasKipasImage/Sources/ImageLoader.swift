import Foundation

public protocol ImageLoader {
    func loadImage(from url: URL) async throws -> Data
}

public final class RemoteImageLoader: ImageLoader {
    
    public enum ImageError: Error {
        case notAnImageContent
        case missingResponseContentTypeHttpHeader
    }
    
    public static var shared: ImageLoader {
        get { _shared }
        set { _shared = newValue }
    }
    
    @Atomic
    private static var _shared: ImageLoader = {
        let client = ImageHTTPClientFactory.create()
        let loader = RemoteImageLoader(client: client)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    private let client: ImageHTTPClient
    
    public init(client: ImageHTTPClient) {
        self.client = client
    }
    
    public func loadImage(from url: URL) async throws -> Data {
        
        if Task.isCancelled {
            try Task.checkCancellation()
        }
        
        let request = URLRequest(url: url)
        
        let task = Task {
            do {
                let (data, response) = try await client.request(from: request)
                
                guard let mimeType = response.mimeType else {
                    throw ImageError.missingResponseContentTypeHttpHeader
                }
                
                guard RemoteImageLoader.validMimeType(mimeType) else {
                    throw ImageError.notAnImageContent
                }
                
                return data
                
            } catch {
                throw error
            }
        }
        
        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }
}

private extension RemoteImageLoader {
    static func validMimeType(_ mimeType: String) -> Bool {
        let validMimeTypes = ["image/jpeg", "image/jpg", "image/pjpeg", "image/png", "image/gif", "application/octet-stream"]
        return validMimeTypes.contains(mimeType)
    }
}

extension MainQueueDispatchDecorator: ImageLoader where T == ImageLoader {
    func loadImage(from url: URL) async throws -> Data {
        try await decoratee.loadImage(from: url)
    }
}
