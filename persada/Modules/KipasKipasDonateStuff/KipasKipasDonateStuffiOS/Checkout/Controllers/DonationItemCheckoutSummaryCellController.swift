import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

final class DonationItemCheckoutSummaryCellController: NSObject {
    
    enum Style {
        case normal
        case bold
    }
    
    private let title: String
    private let detail: String
    private let style: Style
    
    private var cell: DonationItemCheckoutSummaryCell?
  
    init(
        title: String,
        detail: String,
        style: Style = .normal
    ) {
        self.title = title
        self.detail = detail
        self.style = style
    }
}

extension DonationItemCheckoutSummaryCellController {
    private var font: (titleFont: UIFont, detailFont: UIFont) {
        switch style {
        case .normal:
            return (.roboto(.medium, size: 12), .roboto(.regular, size: 14))
        case .bold:
            return (.roboto(.medium, size: 14), .roboto(.medium, size: 14))
        }
    }
    
    private var textColor: (titleColor: UIColor, detailColor: UIColor) {
        switch style {
        case .normal:
            return (.boulder, .night)
        case .bold:
            return (.night, .night)
        }
    }
}

extension DonationItemCheckoutSummaryCellController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.titleLabel.text = title
        cell?.titleLabel.font = font.titleFont
        cell?.titleLabel.textColor = textColor.titleColor
        
        cell?.detailLabel.text = detail
        cell?.detailLabel.font = font.detailFont
        cell?.detailLabel.textColor = textColor.detailColor
        
        return cell!
    }
}

