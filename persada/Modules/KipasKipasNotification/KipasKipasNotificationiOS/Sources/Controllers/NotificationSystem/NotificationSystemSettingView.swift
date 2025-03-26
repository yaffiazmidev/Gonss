import UIKit
import KipasKipasShared

public class NotificationSystemSettingView: UIView {
    
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero)
    private(set) var titleLabel: UILabel = UILabel()
    private(set) var containerView: UIView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NotificationSystemSettingView {
   
    private func configureUI() {
        UIFont.loadCustomFonts
        configureContainerView()
    }
    
    
    private func configureContainerView() {
        addSubview(containerView)
        containerView.anchors.top.equal(safeAreaLayoutGuide.anchors.top)
        containerView.anchors.leading.equal(anchors.leading)
        containerView.anchors.trailing.equal(anchors.trailing)
        containerView.anchors.bottom.equal(anchors.bottom)
        containerView.backgroundColor = UIColor(hexString: "#FBFBFB")
        
        configureTitle()
        configureCollectionView()
    }
    
    private func configureTitle() {
        containerView.addSubview(titleLabel)
        titleLabel.anchors.top.equal(containerView.anchors.top)
        titleLabel.anchors.leading.equal(containerView.anchors.leading, constant: 16)
        titleLabel.anchors.trailing.equal(containerView.anchors.trailing, constant: -16)
        titleLabel.anchors.height.equal(30)
        titleLabel.text = "Kamu bisa membisukan notifikasi dari channel berikut."
        titleLabel.font = .roboto(.regular, size: 12)
        titleLabel.textColor = .grey
        titleLabel.backgroundColor = UIColor(hexString: "#FBFBFB")
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        containerView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(NotificationSystemSettingItemCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.registerHeader(UICollectionReusableView.self)
        collectionView.allowsSelection = true
        
        collectionView.anchors.top.equal(titleLabel.anchors.bottom)
        collectionView.anchors.leading.equal(containerView.anchors.leading)
        collectionView.anchors.trailing.equal(containerView.anchors.trailing, constant: 16)
        collectionView.anchors.bottom.equal(containerView.anchors.bottom)
    }
}
