/*
 * Copyright 2016 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    var centerMapCoordinate:CLLocationCoordinate2D!
    var marker:GMSMarker!
    var address : String!
    var lat : String!
    var long : String!
    
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    let mainView = MapsView.loadViewFromNib()
    
    // Update the map once the user has made their selection.
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Clear the map.
        mapView.clear()
        
        // Add a marker to the map.
        if let place = selectedPlace {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        
        listLikelyPlaces()
    }
    
    
    
    func backToMap(){
        mapView.clear()
        
        // Add a marker to the map.
        if let place = selectedPlace {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        
        listLikelyPlaces()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        let backButton = UIBarButtonItem(image: UIImage(named: .get(.iconBack)), style: .plain, target: self, action: #selector(back))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        self.title = .get(.aturPinPoint)
    }
    
    @objc
    func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // A default location to use when location permission is not granted.
        let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
        
        // Create a map.
        if #available(iOS 14.0, *) {
            let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
            
            let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                                  longitude: defaultLocation.coordinate.longitude,
                                                  zoom: zoomLevel)
            print("Zoom \(zoomLevel)")
            mapView = GMSMapView.map(withFrame: mainView.viewMaps.bounds, camera: camera)
        } else {
            // Fallback on earlier versions
            
//                let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
                
                let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                                      longitude: defaultLocation.coordinate.longitude,
                                                      zoom: 15.0)
                mapView = GMSMapView.map(withFrame: mainView.viewMaps.bounds, camera: camera)

        }
        
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        mainView.viewMaps.addSubview(mapView)
        mapView.isHidden = true
        
        listLikelyPlaces()
        bindClick()
    }
    
    func bindClick() {
        mainView.onClickSearch = {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            autocompleteController.overrideUserInterfaceStyle = .light
            
            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                        UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) )
            autocompleteController.placeFields = fields
            
            // Specify a filter.
            let filter = GMSAutocompleteFilter()
            filter.type = .address
            autocompleteController.autocompleteFilter = filter
            
            // Display the autocomplete view controller.
            self.present(autocompleteController, animated: true, completion: nil)
        }
        
        mainView.onClickSave = {
            guard let viewControllers = self.navigationController?.viewControllers else {
                return
            }

            for firstViewController in viewControllers {
                if firstViewController is EditAddressController {
                    let vc = firstViewController as! EditAddressController
                    vc.backFromMaps(lat: self.lat, long: self.long, address: self.address)
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    override func loadView() {
        view = mainView
        mainView.initView()
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        let placeFields: GMSPlaceField = [.name, .coordinate]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { (placeLikelihoods, error) in
            guard error == nil else {
                // TODO: Handle the error.
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            guard let placeLikelihoods = placeLikelihoods else {
                print("No places found.")
                return
            }
            
            // Get likely places and add to the list.
            for likelihood in placeLikelihoods {
                let place = likelihood.place
                self.likelyPlaces.append(place)
            }
        }
    }
    
    // Prepare the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSelect" {
            if let nextViewController = segue.destination as? PlacesViewController {
                nextViewController.likelyPlaces = likelyPlaces
            }
        }
    }
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        if #available(iOS 14.0, *) {
            let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoomLevel)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        } else {
            // Fallback on earlier versions
//            let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: 15.0)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        }
        
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check accuracy authorization
        if #available(iOS 14.0, *) {
            let accuracy = manager.accuracyAuthorization
            switch accuracy {
            case .fullAccuracy:
                print("Location accuracy is precise.")
            case .reducedAccuracy:
                print("Location accuracy is not precise.")
            @unknown default:
                fatalError()
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        // Handle authorization status
        switch status {
        case .restricted:
            print("Location access was restricted.")
            mapView.isHidden = false
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("Location status is OK.")
            locationManager.startUpdatingLocation()
        @unknown default:
            fatalError()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapViewController : GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let latitude = place.coordinate.latitude
        let longitude = place.coordinate.longitude
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.clear()
        
        if marker == nil {
            marker = GMSMarker()
        }
        marker.position = centerMapCoordinate
        marker.title = selectedPlace?.name
        marker.snippet = selectedPlace?.formattedAddress
        marker.map = mapView
        let post = GMSCameraPosition(target: position, zoom: 15.0)
        mapView.animate(to: post)

        latLong(lat: latitude, long: longitude)
        listLikelyPlaces()
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}


extension MapViewController : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        
        centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.placeMarkerOnCenter(centerMapCoordinate:centerMapCoordinate)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        
        lat = String(latitude)
        long = String(longitude)
        self.latLong(lat: latitude, long: longitude)
    }
    
    func placeMarkerOnCenter(centerMapCoordinate:CLLocationCoordinate2D) {
        if marker == nil {
            marker = GMSMarker()
        }
        marker.icon = UIImage(named: .get(.iconPinPointMaps))

        marker.position = centerMapCoordinate
        marker.map = self.mapView
        
    }
    
    func latLong(lat: Double,long: Double)  {
        
        let geoCoder = CLGeocoder()
        
        let location = CLLocation(latitude: lat , longitude: long)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if let error = error {
                print("Error GeoLocation \(error)")
            }
            
            if let placeMark = placemarks?[0] {
                var address = ""
                
                if let thoroughfare = placeMark.thoroughfare {
                    address = "\(thoroughfare) "
                }
                if let subThoroughfare = placeMark.subThoroughfare {
                    address = "\(address)No. \(subThoroughfare) "
                }
                if let locality = placeMark.locality {
                    address = "\(address)\(locality) "
                }
                if let subLocality = placeMark.subLocality {
                    address = "\(address)\(subLocality) "
                }
                if let postalCode = placeMark.postalCode {
                    address = "\(address)\(postalCode) "
                }
                if let administrativeArea = placeMark.administrativeArea {
                    address = "\(address)\(administrativeArea) "
                }
                if let subAdministrativeArea = placeMark.subAdministrativeArea {
                    address = "\(address)\(subAdministrativeArea) "
                }
                if let country = placeMark.country {
                    address = "\(address)\(country)"
                }
                
                self.address = address
                self.marker.title = placeMark.name
                self.marker.snippet = self.address
                self.mapView.selectedMarker = self.marker
                                
            }
            
        })
    }
}
