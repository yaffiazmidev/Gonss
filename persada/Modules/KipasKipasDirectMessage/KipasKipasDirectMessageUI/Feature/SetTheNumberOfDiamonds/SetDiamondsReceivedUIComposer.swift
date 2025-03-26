import Foundation
import KipasKipasShared
import KipasKipasDirectMessage

final class SetDiamondsReceivedUIComposer {
	private init() {}
	
	public static func setDiamondsReceivedComposeWith(
		accountId: String,
		loader: SetDiamondsReceivedLoader,
		lastDiamondLoader: LastDiamondLoader) -> SetDiamondsReceivedViewController {
			
			let setDiamondsService = SetDiamondsReceivedService(loader: loader)
			let lastDiamondService = LastDiamondService(loader: lastDiamondLoader)
			
			let serviceFactory = SetDiamondsReceivedServiceFactory(setDiamond: setDiamondsService, lastDiamond: lastDiamondService)
			let controller = SetDiamondsReceivedViewController(delegate: serviceFactory, accountId: accountId)
			
			setDiamondsService.presenter = SetDiamondsReceivedPresenter(
				successView: WeakRefVirtualProxy(controller),
				loadingView: WeakRefVirtualProxy(controller),
				errorView: WeakRefVirtualProxy(controller)
			)
			
			lastDiamondService.presenter = LastDiamondPresenter(
				successView: WeakRefVirtualProxy(controller),
				loadingView: WeakRefVirtualProxy(controller),
				errorView: WeakRefVirtualProxy(controller)
			)
			
			return controller
		}
}

extension MainQueueDispatchDecorator: SetDiamondsReceivedLoader where T == SetDiamondsReceivedLoader {
	public func set(request: SetDiamondsReceivedRequest, completion: @escaping (SetDiamondsReceivedLoader.Result) -> Void) {
		decoratee.set(request: request) { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}

extension MainQueueDispatchDecorator: LastDiamondLoader where T == LastDiamondLoader {
	public func load(completion: @escaping (LastDiamondLoader.Result) -> Void) {
		decoratee.load { [weak self] result in
			self?.dispatch { completion(result) }
		}
	}
}

extension WeakRefVirtualProxy: SetDiamondsReceivedView where T: SetDiamondsReceivedView {
	func display(_ viewModel: SetDiamondsReceivedViewModel) {
		object?.display(viewModel)
	}
}
extension WeakRefVirtualProxy: SetDiamondsReceivedLoadingView where T: SetDiamondsReceivedLoadingView {
	func display(_ viewModel: SetDiamondsReceivedLoadingViewModel) {
		object?.display(viewModel)
	}
}
extension WeakRefVirtualProxy: SetDiamondsReceivedLoadingErrorView where T: SetDiamondsReceivedLoadingErrorView {
	func display(_ viewModel: SetDiamondsReceivedLoadingErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: LastDiamondView where T: LastDiamondView {
	func display(_ viewModel: LastDiamondViewModel) {
		object?.display(viewModel)
	}
}
extension WeakRefVirtualProxy: LastDiamondLoadingView where T: LastDiamondLoadingView {
	func display(_ viewModel: LastDiamondLoadingViewModel) {
		object?.display(viewModel)
	}
}
extension WeakRefVirtualProxy: LastDiamondLoadingErrorView where T: LastDiamondLoadingErrorView {
	func display(_ viewModel: LastDiamondLoadingErrorViewModel) {
		object?.display(viewModel)
	}
}
