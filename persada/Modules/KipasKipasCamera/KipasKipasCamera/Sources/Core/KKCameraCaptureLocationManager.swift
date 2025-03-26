import Foundation
import CoreLocation

final class KKCameraCaptureLocationManager: NSObject {
    
    private let locationManager = CLLocationManager()
    
    private var authorizationStatus: CLAuthorizationStatus!
    
    var location: CLLocation? {
        locationManager.location
    }
    
    // Request location authorization so photos and videos can be tagged
    // with their location.
    func checkLocationAuthorizationStatus() {
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
