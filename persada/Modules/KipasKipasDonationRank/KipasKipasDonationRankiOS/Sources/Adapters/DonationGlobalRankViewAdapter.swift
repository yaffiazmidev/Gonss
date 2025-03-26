import UIKit
import KipasKipasDonationRank
import KipasKipasShared

final class DonationGlobalRankViewAdapter {
    
    private weak var controller: DonationGlobalRankViewController?
    
    init(controller: DonationGlobalRankViewController?) {
        self.controller = controller
    }
}

extension DonationGlobalRankViewAdapter: DonationGlobalRankView {
    func display(_ viewModel: DonationGlobalRankViewModel) {
        
        let adapter = DonationGlobalRankImagePresentationAdapter(item: viewModel.items)
        
        let cellControllers = viewModel.items.map {
            DonationGlobalRankCellController(item: $0, delegate: adapter)
        }
        
        controller?.set(cellControllers)
    }
}
