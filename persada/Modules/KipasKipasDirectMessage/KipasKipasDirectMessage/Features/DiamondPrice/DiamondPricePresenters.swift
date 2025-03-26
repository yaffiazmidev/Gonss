import Foundation

class DiamondPricePresenter {
	
	private let successView: DiamondPriceView?
	private let loadingView: DiamondPriceLoadingView?
	private let errorView: DiamondPriceLoadingErrorView?
	
	init(
		successView: DiamondPriceView,
		loadingView: DiamondPriceLoadingView,
		errorView: DiamondPriceLoadingErrorView) {
			self.successView = successView
			self.loadingView = loadingView
			self.errorView = errorView
		}
	
	func didStartLoadingGetDiamondPrice() {
		errorView?.display(.noError)
		loadingView?.display(DiamondPriceLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingGetDiamondPrice(with item: ChatPriceItem) {
		successView?.display(DiamondPriceViewModel(item: item))
		loadingView?.display(DiamondPriceLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingGetDiamondPrice(with error: Error) {
		errorView?.display(.error(message: error.localizedDescription))
		loadingView?.display(DiamondPriceLoadingViewModel(isLoading: false))
	}
}

protocol DiamondPriceView {
	func display(_ viewModel: DiamondPriceViewModel)
}

protocol DiamondPriceLoadingView {
	func display(_ viewModel: DiamondPriceLoadingViewModel)
}

protocol DiamondPriceLoadingErrorView {
	func display(_ viewModel: DiamondPriceLoadingErrorViewModel)
}


struct DiamondPriceViewModel {
	let item: ChatPriceItem
}

struct DiamondPriceLoadingViewModel {
	let isLoading: Bool
}

struct DiamondPriceLoadingErrorViewModel {
	let message: String?
	
	static var noError: DiamondPriceLoadingErrorViewModel {
		return DiamondPriceLoadingErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> DiamondPriceLoadingErrorViewModel {
		return DiamondPriceLoadingErrorViewModel(message: message)
	}
}

