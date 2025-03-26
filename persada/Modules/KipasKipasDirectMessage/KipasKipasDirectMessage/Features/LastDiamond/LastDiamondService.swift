import Foundation

class LastDiamondService: LastDiamondViewControllerDelegate {
	let loader: LastDiamondLoader
	var presenter: LastDiamondPresenter?
	
	init(loader: LastDiamondLoader) {
		self.loader = loader
	}
	
	func didReqeustLastDiamond() {
		presenter?.didStartLoadingGetLastDiamond()
		loader.load { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case let .success(item):
				self.presenter?.didFinishLoadingGetLastDiamond(with: item)
			case let .failure(error):
				self.presenter?.didFinishLoadingGetLastDiamond(with: error)
			}
		}
	}
}
