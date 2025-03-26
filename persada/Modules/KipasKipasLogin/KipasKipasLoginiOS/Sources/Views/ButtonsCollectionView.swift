import UIKit
import KipasKipasShared

final class ButtonsCollectionView: UICollectionView {
    
    var updateTitle: Closure<Bool>?
    
    private var startingYOffset: CGFloat = 0.0
    
    private var isUsingCenteredLayout: Bool {
        return buttons.count <= 5
    }
    
    private var layout: UICollectionViewLayout {
        if isUsingCenteredLayout {
            let layout = CenteredCollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.headerHeight = 120
            return layout
        } else {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            return layout
        }
    }
    
    private let buttons: [UIButton]
    
    init(buttons: [UIButton]) {
        self.buttons = buttons
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        configureCollectionView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
        startingYOffset = contentOffset.y
    }
    
    // MARK: Helpers
    private func configureCollectionView() {
        backgroundColor = .white
        delegate = self
        dataSource = self
        decelerationRate = .fast
        showsVerticalScrollIndicator = false
        collectionViewLayout = layout
        
        registerCell(UICollectionViewCell.self)
        registerHeader(Header.self)
    }
    
    private func shouldUpdateTitle() -> Bool {
        let targetYOffset = startingYOffset + 50
        return contentOffset.y >= targetYOffset
    }
}

extension ButtonsCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(at: indexPath)
        
        let button = buttons[indexPath.item]
        cell.contentView.addSubview(button)
        button.anchors.edges.pin()
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateTitle?(shouldUpdateTitle())
        
        guard isUsingCenteredLayout, isDecelerating else { return }
        
        let currentOffsetY = scrollView.contentOffset.y
        let targetOffsetY = (scrollView.contentSize.height / 2) - (scrollView.bounds.size.height / 2)
        
        if currentOffsetY < targetOffsetY || currentOffsetY > targetOffsetY {
            UIView.animate(withDuration: 0.1) {
                self.setContentOffset(.init(x: 0, y: targetOffsetY), animated: true)
            }
        }
    }
}

extension ButtonsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.bounds.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableHeader(at: indexPath) as Header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var insets = UIEdgeInsets()
        
        if isUsingCenteredLayout {
            insets.top = 50
        }
        
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return isUsingCenteredLayout ? .zero : .init(width: collectionView.bounds.size.width, height: 120)
    }
}


private final class Header: UICollectionReusableView {
    
    let stackView = UIStackView()
    let headingLabel = UILabel()
    let subheadingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureUI() {
        stackView.isUserInteractionEnabled = true
        stackView.axis = .vertical
        
        addSubview(stackView)
        stackView.anchors.edges.pin()
        
        headingLabel.font = .roboto(.bold, size: 24)
        headingLabel.text = "Masuk ke KipasKipas"
        headingLabel.textColor = .night
        headingLabel.textAlignment = .center
        headingLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        subheadingLabel.font = .roboto(.regular, size: 14)
        subheadingLabel.text = "Kelola akun kamu, periksa notifikasi,\n beri komentar di video, dan lainnya."
        subheadingLabel.textColor = .night
        subheadingLabel.textAlignment = .center
        subheadingLabel.numberOfLines = 0
        subheadingLabel.textColor = .boulder
        
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(spacer(8))
        stackView.addArrangedSubview(subheadingLabel)
        stackView.addArrangedSubview(spacer(26))
    }
}
