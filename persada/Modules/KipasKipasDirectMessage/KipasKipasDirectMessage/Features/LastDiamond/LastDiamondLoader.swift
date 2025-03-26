import Foundation
import KipasKipasNetworking

public protocol LastDiamondLoader {
	typealias Result = Swift.Result<ChatDiamondItem, Error>
	
	func load(completion: @escaping(Result) -> Void)
}

class RemoteLastDiamondLoader: LastDiamondLoader {
	
	private var url: URL
	private var client: HTTPClient
	
	public typealias Result = Swift.Result<ChatDiamondItem, Error>
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	func load(completion: @escaping (Result) -> Void) {
		let urlRequest = SetDiamondsReceivedEndpoint.getDiamond.url(baseURL: url)
		
		Task {
			do  {
				let (data, response) = try await client.request(from: urlRequest)
				completion(RemoteLastDiamondLoader.map(data, from: response))
			} catch {
				completion(.failure(KKNetworkError.connectivity))
			}
		}
	}
	
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let item = try LastDiamondItemMapper.map(data, from: response)
			return .success(item)
		} catch {
			return .failure(error)
		}
	}
}

public class LastDiamondItemMapper {
	
	private struct Root: Codable {
		private let code: String?
		private let message: String?
		private let data: ContentData?
		
		private struct ContentData: Codable {
			let lastChangeAt, allowChangeAt, lastSetDiamond, conversionCurrency: Int?
			let maxSetDiamond: Int?
		}
		
		var item: ChatDiamondItem {
			return ChatDiamondItem(lastChange: data?.lastChangeAt ?? 0, allowChangeAt: data?.allowChangeAt ?? 0, lastSetDiamond: data?.lastSetDiamond ?? 0, conversionCurrency: data?.conversionCurrency ?? 0, maxSetDiamond: data?.maxSetDiamond ?? 0)
		}
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> ChatDiamondItem {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw KKNetworkError.invalidData
		}
		
		return root.item
	}
}

public struct ChatDiamondItem {
	public let lastChange: Int
	public let allowChangeAt: Int
	public let lastSetDiamond: Int
	public let conversionCurrency: Int
	public let maxSetDiamond: Int
}
