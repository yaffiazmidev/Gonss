import Foundation
import KipasKipasLogin

class AuthNetworkModel: NetworkModel {
	
    
	func login(_ request: AuthEndpoint, _ completion: @escaping (ResultData<LoginResponse>) -> Void) {
		
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func requestOTP(_ request: AuthEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func verifyOTP(_ request: AuthEndpoint, _ completion: @escaping (ResultData<VerifyOTP>) -> Void) {
		
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func verifyOTPPassword(_ request: AuthEndpoint, _ completion: @escaping (ResultData<VerifyForgotPassword>) -> Void) {
		
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	
	func requestForgotPassword(_ request: AuthEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func forgotPassword(_ request: AuthEndpoint, _ completion: @escaping (ResultData<VerifyForgotPassword>) -> Void) {
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func inputUserInfo(_ request: AuthEndpoint, _ completion: @escaping (ResultData<LoginResponse>) -> Void) {
		
		let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
		let convertString = String(data: dataBody, encoding: .utf8) ?? ""
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = convertString.data(using: .utf16)
		
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.header as? [String: String]
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func showChannels(_ request: AuthEndpoint, completieon: @escaping (ResultData<ChannelCategoryArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completieon)
	}
	
	func followChannels(_ parameter: String? ,_ request: AuthEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = parameter?.data(using: .utf8)
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}
	
	func showArtists(_ request: AuthEndpoint, completieon: @escaping (ResultData<FollowArtistArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completieon)
	}
	
	func followArtists(_ parameter: String? ,_ request: AuthEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.httpBody = parameter?.data(using: .utf8)
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completion)
	}

	func logout(_ request: AuthEndpoint, _ completion: @escaping (ResultData<DefaultResponse>) -> Void) {

		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue

		let encodeRequestUrl = urlRequest.encode(with: request.parameter)

		requestData(encodeRequestUrl, completion)
	}
	
	func searchArtists(_ request: AuthEndpoint, completieon: @escaping (ResultData<FollowArtistArray>) -> Void) {
		
		var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
		urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
		urlRequest.httpMethod = request.method.rawValue
		
		let encodeRequestUrl = urlRequest.encode(with: request.parameter)
		
		requestData(encodeRequestUrl, completieon)
	}
    
    func refreshToken(_ request: AuthEndpoint, completieon: @escaping (ResultData<LoginResponse>) -> Void) {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.allHTTPHeaderFields = request.parameter as? [String: String]
        urlRequest.httpMethod = request.method.rawValue
        
        let encodeRequestUrl = urlRequest.encode(with: request.parameter)
        
        requestData(encodeRequestUrl, completieon)
    }
}

