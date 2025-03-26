//
//  KKQRHelper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 03/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import KipasKipasNetworking

enum KKQRType: String, Codable {
    case shop = "shop"
    case donation = "donation"
}

enum KKQRError: Error {
    case urlNotValid
    case typeNotValid
    case failedRecognize
}

struct KKQRItem: Codable {
    let type: KKQRType
    let id: String
    let data: KKQRDataItem?
    
    init(type: KKQRType, id: String, data: KKQRDataItem? = nil) {
        self.type = type
        self.id = id
        self.data = data
    }
    
    func toJson() -> Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        }
        return nil
    }
    
    static func fromJson(data: Data?) -> KKQRItem?{
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(KKQRItem.self, from: data) {
            return decoded
        }
        return nil
    }
}

struct KKQRDataItem: Codable {
    let name: String
    let price: Int?
    let image: String
    
    init(name: String, price: Int?, image: String) {
        self.name = name
        self.price = price
        self.image = image
    }
}

class KKQRHelper {
    typealias Result = Swift.Result<KKQRItem, KKQRError>
    
    static let userDefaultKey = "userDefaultQR"
    private static let lastItemKey = "userDefaultQRLastItem"
    
    private static let baseUrl = APIConstants.webURL
    private static let regex = "\(APIConstants.webURL)/[A-Za-z]{1,}/[A-Za-z0-9]{1,}"
    
    private static var images: [UIImage] = []
    static var stateAskPhoto : Bool = false
    
    static func decode(_ img: UIImage) -> Result {
        guard
            let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]),
            let ciImage: CIImage = CIImage(image:img),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature]
        else {
            return Result.failure(.failedRecognize)
        }
        
        var code = ""
        features.forEach { feature in
            if let messageString = feature.messageString {
                code += messageString
            }
        }
        
        return parseUrl(code)
    }
    
    static func fetchPhotos () -> [UIImage] {
        images = []
        // Sort the images by descending creation date and fetch the first 3
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            let totalImageCountNeeded = 1 // <-- The number of images to fetch
            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
        }
        return images
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    private static func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Perform the image request
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            if let image = image {
                // Add the returned image to your array
                self.images += [image]
            }
            // If you haven't already reached the first
            // index of the fetch result and if you haven't
            // already stored all of the images you need,
            // perform the fetch request again with an
            // incremented index
            if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            }
        })
    }
    
    static func generate(_ item: KKQRItem, withIcon icon: UIImage? = nil) -> UIImage?{
        let url = buildUrl(item)
        let data = url.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let qr = convert(output)
                
                if let icon = icon{
                    guard let qr = qr else { return nil }
                    let qrWithIcon = mergedImageWith(frontImage: icon, backgroundImage: qr)
                    return qrWithIcon
                }
                
                return qr
            }
        }
        return nil
    }
    
    private static func convert(_ cmage:CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    static func mergedImageWith(frontImage:UIImage?, backgroundImage: UIImage) -> UIImage {
        let size = backgroundImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        backgroundImage.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        frontImage?.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height).insetBy(dx: size.width * 0.4   , dy: size.height * 0.4))
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func fetchPhotosQR(_ controller: UIViewController, _ completion: @escaping (KKQRItem)->()){
        checkPermission(controller, completion)
    }
    
    private static func checkPermission(_ controller: UIViewController, _ completion: @escaping (KKQRItem)->()){
//        if #available(iOS 14, *) {
//            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
//                DispatchQueue.main.async {
//                    checkState(for: status, controller: controller, completion)
//                }
//            }
//        } else {
//            // Fallback on earlier versions
//            let status = PHPhotoLibrary.authorizationStatus()
//            checkState(for: status, controller: controller, completion)
//        }
    }
    
    private static func checkState(for status: PHAuthorizationStatus, controller: UIViewController, _ completion: @escaping (KKQRItem)->()) {
        switch status {
        case .authorized, .limited:
            getPhotos(controller, completion)
            
        case .restricted, .denied, .notDetermined:
            alertAskPhotos(controller)
            
        @unknown default:
            break
        }
    }
    
    private static func alertAskPhotos(_ controller: UIViewController) {
        
        let actionSheet = UIAlertController(title: "",
                                            message: .get(.photosask),
                                            preferredStyle: .alert)
        
        let selectPhotosAction = UIAlertAction(title: .get(.photosselected),
                                               style: .default) { _ in
            // Show limited library picker
            if #available(iOS 14, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
            } else {
                // Fallback on earlier versions
            }
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: .get(.photosaccessall),
                                                  style: .default) {_ in
            // Open app privacy settings
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: .get(.cancel), style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        controller.present(actionSheet, animated: true, completion: nil)
    }
    
    private static func getPhotos(_ controller: UIViewController, _ completion: @escaping (KKQRItem)->()) {
//        if !stateAskPhoto{
//            stateAskPhoto.toggle()
//            let photos = fetchPhotos()
//            if let firstImg = photos.first{
//                let result = decode(firstImg)
//                switch result {
//                case let .success(item): handleQRItem(controller, item, completion)
//                default: break
//                }
//            }
//        }
    }
    
    private static func handleQRItem(_ controller: UIViewController, _ item: KKQRItem, _ completion: @escaping (KKQRItem)->()){
        let data = UserDefaults.standard.object(forKey: lastItemKey) as? Data
        let userItem = KKQRItem.fromJson(data: data)
        
        if UserDefaults.standard.bool(forKey: userDefaultKey) || (userItem?.type != item.type && userItem?.id != item.id) {
            //load data from cache first
            if userItem?.data != nil && item.type == userItem?.type && item.id == userItem?.id {
                showDialog(controller, userItem!, completion)
                return
            }
            
            if item.type == .shop {
                createLoader().productLoader.load(request: .init(id: item.id, isPublic: !AUTH.isLogin())) { result in
                    switch result {
                    case let .success(product):
                        guard let name = product.name, let price = product.price, let url = product.medias?.first?.thumbnail?.medium else { return }
                        let item = KKQRItem(type: item.type, id: item.id, data: KKQRDataItem(name: name, price: price, image: url))
                        if let data = item.toJson() {
                            UserDefaults.standard.set(data, forKey: lastItemKey)
                        }
                        DispatchQueue.main.async {
                            showDialog(controller, item, completion)
                        }
                    case let .failure(_): break
                    }
                }
                return
            }
            
            if item.type == .donation {
                createLoader().donationLoader.load(request: .init(id: item.id, isPublic: !AUTH.isLogin())) { result in
                    switch result {
                    case let .success(donation):
                        guard let name = donation.title, let url = donation.medias?.first?.thumbnail?.medium else { return }
                        let item = KKQRItem(type: item.type, id: item.id, data: KKQRDataItem(name: name, price: nil, image: url))
                        if let data = item.toJson() {
                            UserDefaults.standard.set(data, forKey: lastItemKey)
                        }
                        DispatchQueue.main.async {
                            showDialog(controller, item, completion)
                        }
                    case let .failure(_): break
                    }
                }
                return
            }
            
        }
    }
    
    private static func showDialog(_ controller: UIViewController, _ item: KKQRItem, _ completion: @escaping (KKQRItem)->()){
        let vc = KKQRNotifDialogViewController(item: item)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        controller.present(vc, animated: true)
        
        vc.didClose = {
            UserDefaults.standard.set(false, forKey: userDefaultKey)
        }
        
        vc.didOpen = {
            completion(item)
            NotificationCenter.default.post(name: .qrNotificationKey, object: nil, userInfo: ["QRItem" : item])
            UserDefaults.standard.set(false, forKey: userDefaultKey)
        }
    }
}

// MARK: - URL Handling
extension KKQRHelper {
    private static func buildUrl(_ item: KKQRItem) -> String {
        return baseUrl + "/\(item.type.rawValue)/\(item.id)"
    }
    
    static func parseUrl(_ url: String) -> Result {
        let urls = url.matches(regex: self.regex)
        if urls.isEmpty {
            return Result.failure(.urlNotValid)
        }
        let strings = url.split(separator: "/")
        let id = String(describing: strings.last ?? "")
        let type = String(describing:  strings[strings.count - 2])
        guard let type = KKQRType(rawValue: type) else {
            return Result.failure(.typeNotValid)
        }
        return Result.success(KKQRItem(type: type, id: id))
    }
}

// MARK: - Networking
fileprivate extension KKQRHelper {
//    private static func createLoader() -> (productLoader: QRProductLoader){
    private static func createLoader() -> (productLoader: QRProductLoader, donationLoader: QRDonationLoader){
        let url = URL(string: APIConstants.baseURL)!
        let client = AUTH.isLogin() ? makeHTTPClient().authHTTPClient : makeHTTPClient().httpClient
        let productLoader = RemoteQRProductLoader(url: url, client: client)
        let donationLoader = RemoteQRDonationLoader(url: url, client: client)

        return (productLoader, donationLoader)
    }
    
    static private func makeHTTPClient() -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        
        let baseURL = URL(string: APIConstants.baseURL)!
        
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))

        let localTokenLoader = LocalTokenLoader(store: makeKeychainTokenStore())
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: remoteTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: makeKeychainTokenStore(), loader: tokenLoader)
        
        return (httpClient, authHTTPClient)
    }
    
    static private func makeKeychainTokenStore() -> TokenStore {
        return KeychainTokenStore()
    }
}

fileprivate extension String {
    func matches(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.map { match in
            return String(self[Range(match.range, in: self)!])
        }
    }
}
