import Foundation

class SetDiamondsReceivedPresenter {
	
	private let successView: SetDiamondsReceivedView?
	private let loadingView: SetDiamondsReceivedLoadingView?
	private let errorView: SetDiamondsReceivedLoadingErrorView?
	
	init(
		successView: SetDiamondsReceivedView,
		loadingView: SetDiamondsReceivedLoadingView,
		errorView: SetDiamondsReceivedLoadingErrorView) {
			self.successView = successView
			self.loadingView = loadingView
			self.errorView = errorView
		}
	
	func didStartLoadingGetSetDiamondsReceived() {
		errorView?.display(.noError)
		loadingView?.display(SetDiamondsReceivedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingGetSetDiamondsReceived(with item: SetDiamondsReceivedGeneral) {
		successView?.display(SetDiamondsReceivedViewModel(item: item))
		loadingView?.display(SetDiamondsReceivedLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingGetSetDiamondsReceived(with error: Error) {
		errorView?.display(.error(message: error.localizedDescription))
		loadingView?.display(SetDiamondsReceivedLoadingViewModel(isLoading: false))
	}
}

protocol SetDiamondsReceivedView {
	func display(_ viewModel: SetDiamondsReceivedViewModel)
}

protocol SetDiamondsReceivedLoadingView {
	func display(_ viewModel: SetDiamondsReceivedLoadingViewModel)
}

protocol SetDiamondsReceivedLoadingErrorView {
	func display(_ viewModel: SetDiamondsReceivedLoadingErrorViewModel)
}


struct SetDiamondsReceivedViewModel {
	let item: SetDiamondsReceivedGeneral
}

struct SetDiamondsReceivedLoadingViewModel {
	let isLoading: Bool
}

struct SetDiamondsReceivedLoadingErrorViewModel {
	let message: String?
	
	static var noError: SetDiamondsReceivedLoadingErrorViewModel {
		return SetDiamondsReceivedLoadingErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> SetDiamondsReceivedLoadingErrorViewModel {
		return SetDiamondsReceivedLoadingErrorViewModel(message: message)
	}
}

