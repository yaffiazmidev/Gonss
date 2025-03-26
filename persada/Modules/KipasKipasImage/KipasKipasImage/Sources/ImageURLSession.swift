import Foundation

public final class ImageURLSession {
    
    private static var currentSession: URLSession!
    
    public static func createSession(
        with configuration: URLSessionConfiguration = ImageURLSessionConfiguration.default
    ) -> URLSession {
        
        if currentSession == nil {
            currentSession = URLSession(configuration: configuration)
        }
        
        return currentSession
    }
    
    public static func observe() {
        ImageDownloadSettings.addObserver(self) { oldSettings in
            if oldSettings != ImageDownloadSettings.requestSettings {
                currentSession = nil
            }
        }
    }
    
    /// Calls `finishTasksAndInvalidate` on the current session. A new session will be created for future downloads.
    public static func clearSession() {
        currentSession?.finishTasksAndInvalidate()
        currentSession = nil
    }
}
