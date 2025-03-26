import Foundation
import KipasKipasDirectMessage

class SetDiamondsReceivedServiceFactory: SetDiamondDelegate {
	private let setDiamond: SetDiamondsReceivedViewControllerDelegate
	private let lastDiamond: LastDiamondViewControllerDelegate
	
	init(setDiamond: SetDiamondsReceivedViewControllerDelegate,  lastDiamond: LastDiamondViewControllerDelegate) {
		self.setDiamond = setDiamond
		self.lastDiamond = lastDiamond
	}
	
	func didReqeustLastDiamond() {
		lastDiamond.didReqeustLastDiamond()
	}
	
	func didRequestSetDiamondsReceiveds(request: SetDiamondsReceivedRequest) {
		setDiamond.didRequestSetDiamondsReceiveds(request: request)
	}
}
