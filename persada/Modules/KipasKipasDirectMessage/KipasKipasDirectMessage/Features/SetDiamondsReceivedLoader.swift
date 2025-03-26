
import Foundation
import KipasKipasNetworking

public protocol SetDiamondsReceivedLoader {
	typealias Result = Swift.Result<SetDiamondsReceivedGeneral, Error>
	func set(request: SetDiamondsReceivedRequest, completion: @escaping (Result) -> Void)
}

public class RemoteSetDiamondsReceivedLoader: SetDiamondsReceivedLoader {
	
	public var url: URL
	public var client: HTTPClient
	
	public typealias Result = Swift.Result<SetDiamondsReceivedGeneral, Error>
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func set(request: SetDiamondsReceivedRequest, completion: @escaping (Result) -> Void) {
		let urlRequest = SetDiamondsReceivedEndpoint.set(request: request).url(baseURL: url)
		Task {
			do  {
				let (data, response) = try await client.request(from: urlRequest)
				completion(RemoteSetDiamondsReceivedLoader.map(data, from: response))
			} catch {
				completion(.failure(KKNetworkError.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try SetDiamondsReceivedItemMapper.map(data, from: response)
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
}

class SetDiamondsReceivedItemMapper {
	
	private struct Root: Codable {
		private let code: String?
		private let message: String?
		private let data: String?
		
		var item: SetDiamondsReceivedGeneral {
			return SetDiamondsReceivedGeneral(code: code ?? "", message: message ?? "")
		}
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> SetDiamondsReceivedGeneral {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw KKNetworkError.invalidData
		}
		
		return root.item
	}
}

enum SetDiamondsReceivedEndpoint {
	case set(request: SetDiamondsReceivedRequest)
	case getDiamond
	case getPrice(request: String)
	
	func url(baseURL: URL) -> URLRequest {
		switch self {
		case let .set(request):
			var components = URLComponents()
			components.scheme = baseURL.scheme
			components.host = baseURL.host
			components.path = baseURL.path + "/chat/diamond/setting/me"
			
			var urlRequest = URLRequest(url: components.url!)
			urlRequest.httpMethod = "POST"
			urlRequest.httpBody = try? JSONEncoder().encode(request)
			return urlRequest
		case let .getPrice(id):
			var components = URLComponents()
			components.scheme = baseURL.scheme
			components.host = baseURL.host
			
			components.path = baseURL.path + "/chat/diamond/setting/account/\(id)"
			

			var urlRequest = URLRequest(url: components.url!)
			urlRequest.httpMethod = "GET"
			return urlRequest
		case .getDiamond:
			var components = URLComponents()
			components.scheme = baseURL.scheme
			components.host = baseURL.host
			
			components.path = baseURL.path + "/chat/diamond/setting/me"

			var urlRequest = URLRequest(url: components.url!)
			urlRequest.httpMethod = "GET"
			return urlRequest
		}
	}
}

public struct SetDiamondsReceivedRequest: Encodable {
	public var chatPrice: Int
}

public struct SetDiamondsReceivedGeneral {
	public let code: String
	public let message: String
}
