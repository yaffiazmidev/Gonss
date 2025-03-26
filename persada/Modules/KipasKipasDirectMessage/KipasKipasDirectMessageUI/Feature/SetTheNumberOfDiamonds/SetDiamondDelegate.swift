import Foundation
import KipasKipasDirectMessage

protocol SetDiamondsReceivedViewControllerDelegate {
	func didRequestSetDiamondsReceiveds(request: SetDiamondsReceivedRequest)
}

protocol DiamondPriceViewControllerDelegate {
	func didRequestDiamondPrice(request: String)
}



typealias SetDiamondDelegate = SetDiamondsReceivedViewControllerDelegate & LastDiamondViewControllerDelegate
