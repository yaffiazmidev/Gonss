//
//  DiamondPriceLoader.swift
//  KipasKipasDirectMessageUI
//
//  Created by Muhammad Noor on 19/12/23.
//

import Foundation
import KipasKipasNetworking
import KipasKipasShared

public protocol DiamondPriceLoader{
	typealias Result = Swift.Result<ChatPriceItem, Error>
	
	func load(request: String, completion: @escaping(Result) -> Void)
}

class RemoteDiamondPriceLoader: DiamondPriceLoader{
	
	private var url: URL
	private var client: HTTPClient
	
	public typealias Result = Swift.Result<ChatPriceItem, Error>
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	func load(request: String, completion: @escaping (Result) -> Void) {
		let urlRequest = SetDiamondsReceivedEndpoint.getPrice(request: request).url(baseURL: url)
		
		Task {
			do  {
				let (data, response) = try await client.request(from: urlRequest)
				completion(RemoteDiamondPriceLoader.map(data, from: response))
			} catch {
				completion(.failure(KKNetworkError.connectivity))
			}
		}
	}
	
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let item = try DiamondPriceItemMapper.map(data, from: response)
			return .success(item)
		} catch {
			return .failure(error)
		}
	}
}

class DiamondPriceItemMapper {
	
	private struct Root: Codable {
		private let code: String?
		private let message: String?
		private let data: ContentData?
		
		private struct ContentData: Codable {
			let chatPrice: Int?
		}
		
		var item: ChatPriceItem {
			return ChatPriceItem(price: data?.chatPrice ?? 0)
		}
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> ChatPriceItem {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw KKNetworkError.invalidData
		}
		
		return root.item
	}
}

public struct ChatPriceItem {
	public let price: Int
}

protocol LastDiamondViewControllerDelegate {
	func didReqeustLastDiamond()
}
extension MainQueueDispatchDecorator: DiamondPriceLoader where T == DiamondPriceLoader {
	
	public func load(request: String, completion: @escaping (DiamondPriceLoader.Result) -> Void) {
		decoratee.load(request: request) { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}
extension WeakRefVirtualProxy: DiamondPriceView where T: DiamondPriceView {
	func display(_ viewModel: DiamondPriceViewModel) {
		object?.display(viewModel)
	}
}
extension WeakRefVirtualProxy: DiamondPriceLoadingView where T: DiamondPriceLoadingView {
	func display(_ viewModel: DiamondPriceLoadingViewModel) {
		object?.display(viewModel)
	}
}
extension WeakRefVirtualProxy: DiamondPriceLoadingErrorView where T: DiamondPriceLoadingErrorView {
	func display(_ viewModel: DiamondPriceLoadingErrorViewModel) {
		object?.display(viewModel)
	}
}
