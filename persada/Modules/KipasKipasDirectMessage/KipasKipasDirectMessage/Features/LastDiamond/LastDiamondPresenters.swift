import Foundation

class LastDiamondPresenter {
	
	private let successView: LastDiamondView?
	private let loadingView: LastDiamondLoadingView?
	private let errorView: LastDiamondLoadingErrorView?
	
	init(
		successView: LastDiamondView,
		loadingView: LastDiamondLoadingView,
		errorView: LastDiamondLoadingErrorView) {
			self.successView = successView
			self.loadingView = loadingView
			self.errorView = errorView
		}
	
	func didStartLoadingGetLastDiamond() {
		errorView?.display(.noError)
		loadingView?.display(LastDiamondLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingGetLastDiamond(with item: ChatDiamondItem) {
		successView?.display(LastDiamondViewModel(item: item))
		loadingView?.display(LastDiamondLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingGetLastDiamond(with error: Error) {
		errorView?.display(.error(message: error.localizedDescription))
		loadingView?.display(LastDiamondLoadingViewModel(isLoading: false))
	}
}

protocol LastDiamondView {
	func display(_ viewModel: LastDiamondViewModel)
}

protocol LastDiamondLoadingView {
	func display(_ viewModel: LastDiamondLoadingViewModel)
}

protocol LastDiamondLoadingErrorView {
	func display(_ viewModel: LastDiamondLoadingErrorViewModel)
}


struct LastDiamondViewModel {
	let item: ChatDiamondItem
}

struct LastDiamondLoadingViewModel {
	let isLoading: Bool
}

struct LastDiamondLoadingErrorViewModel {
	let message: String?
	
	static var noError: LastDiamondLoadingErrorViewModel {
		return LastDiamondLoadingErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> LastDiamondLoadingErrorViewModel {
		return LastDiamondLoadingErrorViewModel(message: message)
	}
}

