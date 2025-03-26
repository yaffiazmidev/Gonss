import Foundation

extension URL {
    static var temporaryImagePath: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("kipaskipas-temp-image")
            .appendingPathExtension("jpeg")
    }
    
    static var temporaryVideoPath: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("kipaskipas-temp-video")
            .appendingPathExtension("mp4")
    }
}

public extension Data {
    func writeToTemporaryImagePath() throws -> URL {
        let url = URL.temporaryImagePath
        try write(to: url)
        return url
    }
}
