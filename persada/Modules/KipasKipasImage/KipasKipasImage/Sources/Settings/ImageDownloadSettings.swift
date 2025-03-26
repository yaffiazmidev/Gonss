import Foundation

public final class ImageDownloadSettings {
    
    public static var requestSettings = ImageRequestSettings() {
        didSet {
            notifySettingsChanged(oldValue)
        }
    }
    
    private static var observers = [ObjectIdentifier: (ImageRequestSettings) -> Void]()
    
    internal static func addObserver(_ observer: AnyObject, handler: @escaping (ImageRequestSettings) -> Void) {
        let identifier = ObjectIdentifier(observer)
        observers[identifier] = handler
        handler(requestSettings)
    }
    
    internal static func removeObserver(_ observer: AnyObject) {
        let identifier = ObjectIdentifier(observer)
        observers.removeValue(forKey: identifier)
    }
    
    private static func notifySettingsChanged(_ settings: ImageRequestSettings) {
        observers.values.forEach { $0(settings) }
    }
}
