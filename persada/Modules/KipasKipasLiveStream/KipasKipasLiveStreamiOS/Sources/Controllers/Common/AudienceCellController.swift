import UIKit
import KipasKipasShared

public final class AudienceCellController: CellController {
    
    private let userId: String
    private let name: String
    private let image: String
    private let selection: (String) -> Void
    private let totalCoin: Int
    private let isReward: Bool
    private var cell: AudienceCell?
    
    public init(
        userId: String,
        name: String,
        image: String,
        totalCoin: Int,
        isReward : Bool,
        selection: @escaping (String) -> Void
    ) {
        self.userId = userId
        self.name = name
        self.image = image
        self.totalCoin = totalCoin
        self.isReward = isReward
        self.selection = selection
    }
    
    public override func view(_ collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(at: indexPath)
        cell?.nameLabel.text = name
        cell?.coinLabel.text = getCoinText()
        cell?.numLabel.textColor = (totalCoin > 0 && indexPath.row < 3) ? .watermelon : .gravel
        cell?.numLabel.text =   getNumText(indexPath.row+1)
//        cell?.setRankIcon( totalCoin > 0 ? indexPath.row+1 : 0)
        cell?.setRankImgView( totalCoin > 0 ? userId : "")
        
        if isReward {
            cell?.numLabel.anchors.width.greaterThanOrEqual(16)
        }else{
            cell?.numLabel.anchors.width.equal(0)
        }
        
        if !image.isEmpty {
            cell?.imageView.setImage(with: image)
            cell?.imageView.contentMode = .scaleAspectFill
        }
        
        return cell!
    }
    
    private func getNumText(_ num :Int) -> String {
        if !isReward {
            return ""
        }else if isReward && totalCoin > 0 {
             return "\(num)"
        }else {
            return "-"
        }
    }
    
    private func getCoinText() -> String {
                if totalCoin == 0{
                    return ""
                }else if totalCoin <= 10 {
                    return "\(totalCoin)"
                }else if totalCoin <= 100 {
                    return "\(totalCoin/10)0+"
                }else if totalCoin <= 1000 {
                    return "\(totalCoin/100)00+"
                }else {
                    return "\(totalCoin/1000)K+"
                }
    }
    
    public override func select() {
        selection(userId)
    }
    
    func releaseForReuse() {
        cell = nil
    }
}
