//
//  ViewController.swift
//  KKCleepsApp
//
//  Created by PT.Koanba on 12/05/22.
//

import UIKit
import FeedCleeps
import AVFoundation

class APIConstants {
    private static let bundle = Bundle.init(identifier: "com.koanba.kipaskipas.mobile.KKCleepsApp")

    static var baseURL: String { return APIConstants.prod }

    static var prod: String { return bundle?.infoDictionary!  ["API_BASE_URL_PROD"] as! String }
    static var staging: String { return bundle?.infoDictionary!  ["API_BASE_URL_STAGING"] as! String }
    static var testing: String { return bundle?.infoDictionary!  ["API_BASE_URL_TESTING"] as! String }
}

class DummyRefreshToken: RefreshTokenLoader {
    func requestNotReturnFeedCleeps(request: URLRequest, completion: @escaping (Result<Data?, FeedCleeps.NetworkErrorFeedCleeps>) -> Void, token: @escaping (String) -> Void) {
        //do nothing
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var videoContainer: UIView!
    
    private(set) public lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    
    private(set) public var player: AVQueuePlayer?
    private(set) public var playerLooper: AVPlayerLooper?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let url = URL(string: getMediaProxyUrl())!
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        
        self.playerLayer.frame = videoContainer.bounds
        self.playerLayer.player = player
//        videoContainer.layer.addSublayer(playerLayer)
//        player.play()
//        doLogin(toTiktokCountry: .indo)
        
    }
    
    func getMediaProxyUrl() -> String {
        let hlsURL = "https://asset.kipaskipas.com/media/stream/1664242859068/1664242859068.m3u8"

        return "http://127.0.0.1:8080/" + getVideoId(urlPath: hlsURL) + "/main.m3u8?x=" + hlsURL + "&priority=true"
    }
    
    private func getVideoId(urlPath: String) -> String {
        var videoId = ""
        if(urlPath != "") {
            let pathOfUrl = urlPath.components(separatedBy: "/")
            videoId = pathOfUrl[pathOfUrl.count-2]
        }
        return videoId
    }
    
    func doLogin(toTiktokCountry country : CleepsCountry){
        DummyLogin().login(baseURL: APIConstants.baseURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.routeToFeedCleeps(token: token.token!)
            case .failure(let error):
                print("Error \(error)")
//                self.doLogin(toTiktokCountry: country)
            }
        }
    }

    func routeToFeedCleeps(token: String) {
//        DispatchQueue.main.async {
//
//            // Feed section - start
//            //let identifier = "FEED"
////            let identifier = "general" // purpose: to match with feed channel JSON
////            let loader = RemoteFeedModuleLoader(baseURL: APIConstants.baseURL, token: token)
//            // Feed section - finish
//
//            // Cleeps section - start
//            let cleepsCountry = CleepsCountry.china
//            let identifier = cleepsCountry.rawValue
//            let loader = RemoteFeedCleepsModuleLoader(cleepsCountry: cleepsCountry, baseURL: APIConstants.baseURL, token: token, isTokenExpired: false, refreshTokenService: DummyRefreshToken())
//            // Cleeps section - finish
//
//
//            let view = FeedCleepsView()
//            let param = FeedCleepsPresenterParam(token: token, isLogin: true, userID: "anyID", endpoint: APIConstants.baseURL)
//            let presenter = FeedCleepsPresenter(loader: loader, identifier: identifier, param: param)
//
//            let vc = FeedCleepsViewController(mainView: view, feed: [], presenter: presenter, isLogin: true) { feed, vc in
//            } onShowReportPopUp: { _ in
//            } onClickProfile: { _, _, _ in
//            } onClickHashtag: { _, _ in
//            } onClickUsername: { _ in
//            } onShowAuthPopUp: { _ in
//            } onClickComment: { _, _, _, _ in
//            } onClickProductDetail: { _, _, _ in
//            } onClickGoToLogin: { _ in
//            } onClickEmptyProfile: { _ in
//            } onClickProductBg: { _, _ in
//            }
//
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }

}

class DummyLogin {
    
    typealias Result = Swift.Result<LoginResponse, Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func login(baseURL: String, completion: @escaping (Result) -> Void ) {
        let url = URL(string: "\(baseURL)/auth/login")!
        
        let body = [
            "username" : "ahyakamil",
            "password" : "Mabes132",
            "deviceId" : UIDevice.current.identifierForVendor?.uuidString
        ]
        
        print("URLNYA \(url)")
        
        let dataBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = dataBody
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
         
        let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data, let root = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                completion(.failure(Error.invalidData))
                return
            }
                        
            completion(.success(root))
        }
        task.resume()
    }
}

struct LoginResponse: Decodable {
    let access_token, tokenType, refresh_token: String?
    let expires_in: Int?
    let scope: String?
    let userNo: Int?
    let userName: String?
    let userEmail: String?
    let userMobile, accountID: String?
    let appSource, code: String?
    let timelapse: Int?
    let role, jti, token, refreshToken: String?
}
