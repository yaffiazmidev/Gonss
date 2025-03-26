import Foundation

class SetDiamondsReceivedService: SetDiamondsReceivedViewControllerDelegate {
	
	let loader: SetDiamondsReceivedLoader
	var presenter: SetDiamondsReceivedPresenter?
	
	init(loader: SetDiamondsReceivedLoader) {
		self.loader = loader
	}
	
	func didRequestSetDiamondsReceiveds(request: SetDiamondsReceivedRequest) {
		presenter?.didStartLoadingGetSetDiamondsReceived()
		loader.set(request: request) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case let .success(item):
				self.presenter?.didFinishLoadingGetSetDiamondsReceived(with: item)
			case let .failure(error):
				self.presenter?.didFinishLoadingGetSetDiamondsReceived(with: error)
			}
		}
	}
	
}

