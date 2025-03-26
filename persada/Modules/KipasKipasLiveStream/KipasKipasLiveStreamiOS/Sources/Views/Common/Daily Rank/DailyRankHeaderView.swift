import UIKit
import KipasKipasLiveStream
import KipasKipasShared

final class DailyRankHeaderView: UICollectionReusableView {
    
    private let stack = UIStackView()
    private let refreshCountdownLabel = UILabel()
    
    private let rankContainer = UIView()
    private let rankStackView = UIStackView()
    
    private let firstRankView = TopRankView()
    private let secondRankView = TopRankView()
    private let thirdRankView = TopRankView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    } 
    
    // MARK: API
    func setTopRanks(
        _ viewModels: [LiveDailyRankViewModel],
        selection: @escaping (String) -> Void
    ) {
        let firstRank = viewModels[safe: 0]
        firstRankView.configure(with: firstRank, rank: 1)
        firstRankView.onTap {
            if let id = firstRank?.userId {
                selection(id)
            }
        }
          
        let secondRank = viewModels[safe: 1]
        secondRankView.configure(with: secondRank, rank: 2)
        secondRankView.onTap {
            if let id = secondRank?.userId {
                selection(id)
            }
        }
        
        let thirdRank = viewModels[safe: 2]
        thirdRankView.configure(with: thirdRank, rank: 3)
        thirdRankView.onTap {
            if let id = thirdRank?.userId {
                selection(id)
            }
        }
        
        rankContainer.isHidden = viewModels.isEmpty
    }
}

// MARK: UI
private extension DailyRankHeaderView {
    func configureUI() {
        configureStack()
    }
    
    func configureStack() {
        stack.backgroundColor = .white
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 16
        
        addSubview(stack)
        stack.anchors.edges.pin()
        
        configureSpacing()
//        configureRefreshCountdownLabel()
        configureRankContainer()
    }
    
    func configureSpacing() {
        let spacer = UIView()
        spacer.backgroundColor = .white
        spacer.anchors.height.equal(2)
        
        stack.addArrangedSubview(spacer)
    }
    
//    func configureRefreshCountdownLabel() {
//        let topView  = UIView()
//        stack.addArrangedSubview(topView)
//        topView.anchors.edges.pin(axis:.horizontal)
//        topView.anchors.height.equal(19)
//        
//        refreshCountdownLabel.text = "Next update: "
//        refreshCountdownLabel.font = .roboto(.medium, size: 13)
//        refreshCountdownLabel.textColor = .boulder
//        refreshCountdownLabel.textAlignment = .center
//        topView.addSubview(refreshCountdownLabel)
//        refreshCountdownLabel.anchors.leading.pin()
//        refreshCountdownLabel.anchors.edges.pin(axis:.vertical)
//         
//        let rightView  = UIView()
//        rightView.backgroundColor = UIColor.init(hexString: "#FDF5E7")
//        rightView.layer.cornerRadius = 4
//        topView.addSubview(rightView)
//        rightView.anchors.trailing.pin()
//        rightView.anchors.edges.pin(axis:.vertical)
//        
//        let  historyLabel = UILabel()
//        historyLabel.text = "Ranking history"
//        historyLabel.textColor = UIColor.init(hexString: "#F7A541")
//        historyLabel.font = .roboto(.medium, size: 10)
//        rightView.addSubview(historyLabel)
//        historyLabel.anchors.trailing.pin(inset: 7)
//        historyLabel.anchors.centerY.align()
//        
//        let iconImageV = UIImageView()
//        iconImageV.image = .iconRankingBadge
//        rightView.addSubview(iconImageV)
//        iconImageV.anchors.centerY.align()
//        iconImageV.anchors.trailing.equal(historyLabel.anchors.leading, constant: -4.5)
//        iconImageV.anchors.leading.pin()
//        
//    }
    
    func configureRankContainer() {
        stack.addArrangedSubview(rankContainer)
        rankContainer.anchors.width.equal(anchors.width)
        
        rankStackView.distribution = .fillEqually
        rankStackView.spacing = 5
        rankStackView.alignment = .bottom
        
        rankContainer.addSubview(rankStackView)
        rankStackView.anchors.edges.pin()
        
        rankStackView.addArrangedSubview(secondRankView)
        secondRankView.anchors.height.equal(128)
        
        rankStackView.addArrangedSubview(firstRankView)
        firstRankView.anchors.height.equal(150)
        
        rankStackView.addArrangedSubview(thirdRankView)
        thirdRankView.anchors.height.equal(128)
    }
}
