import Foundation

class DiamondPriceService: DiamondPriceViewControllerDelegate {
	
	let loader: DiamondPriceLoader
	var presenter: DiamondPricePresenter?
	
	init(loader: DiamondPriceLoader) {
		self.loader = loader
	}
	
	func didRequestDiamondPrice(request: String) {
		presenter?.didStartLoadingGetDiamondPrice()
		loader.load(request: request) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case let .success(item):
				self.presenter?.didFinishLoadingGetDiamondPrice(with: item)
			case let .failure(error):
				self.presenter?.didFinishLoadingGetDiamondPrice(with: error)
			}
		}
	}
}
