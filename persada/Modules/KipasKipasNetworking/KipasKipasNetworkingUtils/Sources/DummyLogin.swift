import Foundation
import KipasKipasNetworking

private struct LoginResponse: Decodable {
    let access_token, tokenType, refresh_token: String?
    let expires_in: Int?
    let scope: String?
    let userNo: Int?
    let userName: String?
    let userEmail: String?
    let userMobile, accountId: String?
    let appSource, code: String?
    let timelapse: Int?
    let role, jti, token, refreshToken: String?
}

public struct DummyLoginCredential {
    public let username: String
    public let password: String
    public let deviceID: String?
    
    public init(username: String, password: String, deviceID: String?) {
        self.username = username
        self.password = password
        self.deviceID = deviceID
    }
}

public final class DummyLogin {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case saveTokenError
    }
    
    private let credential: DummyLoginCredential
    private let tokenStore: TokenStore
    
    public init(
        credential: DummyLoginCredential,
        tokenStore: TokenStore
    ) {
        self.credential = credential
        self.tokenStore = tokenStore
    }
    
    public func login(baseURL: String, completion: @escaping (Error?) -> Void ) {
        let url = URL(string: "\(baseURL)/auth/login")!
        
        let body = [
            "username" : credential.username,
            "password" : credential.password,
            "deviceId" : credential.deviceID
        ]
        
        let dataBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = dataBody
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let data = data,
                      let root = try? JSONDecoder().decode(
                        LoginResponse.self,
                        from: data
                      ) else {
                    return completion(.invalidData)
                }
                
                let item = LocalTokenItem(
                    accessToken: root.access_token!,
                    refreshToken: root.refreshToken!,
                    expiresIn: Date(timeIntervalSince1970: TimeInterval(root.expires_in!))
                )
                
                if let accountId = root.accountId {
                    DummyLoginCache.instance.save(accountId, forKey: .accountId)
                }
                
                self.tokenStore.insert(item) { result in
                    switch result {
                    case .success:
                        DummyLoginCache.instance.save(true, forKey: .isLoggedIn)
                        completion(nil)
                    case .failure:
                        DummyLoginCache.instance.save(false, forKey: .isLoggedIn)
                        completion(.saveTokenError)
                    }
                }
            }
        }
        task.resume()
    }
}
