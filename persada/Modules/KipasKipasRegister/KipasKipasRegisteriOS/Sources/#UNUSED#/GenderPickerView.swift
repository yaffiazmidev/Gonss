import UIKit
import KipasKipasShared

final class GenderPickerView: UIView {
    
    struct Gender {
        let image: UIImage?
        let code: String
        let name: String
        
        init(
            image: UIImage?,
            code: String,
            name: String
        ) {
            self.image = image
            self.code = code
            self.name = name
        }
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let genders: [Gender] = [
        .init(image: .personMale, code: "MALE", name: "Pria"),
        .init(image: .personFemale, code: "FEMALE", name: "Wanita"),
        .init(image: .personMaleFemale, code: "UNKNOWN", name: "Tidak ingin diketahui")
    ]
    
    private var selectedIndexPath: IndexPath? {
        didSet {
            if let selectedIndexPath {
                didSelectGender?(genders[selectedIndexPath.item])
            } else {
                didSelectGender?(nil)
            }
        }
    }
    
    var didSelectGender: ((Gender?) -> Void)?
    
    private var heightConstraint: NSLayoutConstraint! {
        didSet {
            heightConstraint.isActive = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraint()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UI
private extension GenderPickerView {
    func configureUI() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerCell(GenderCell.self)
        collectionView.registerHeader(UICollectionReusableView.self)
        
        addSubview(collectionView)
        collectionView.anchors.edges.pin()
    }
    
    func setConstraint() {
        if let _ = superview {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.layoutIfNeeded()
            heightConstraint.constant = collectionView.contentSize.height
        }
    }
}

// MARK: UICollectionViewDataSource {
extension GenderPickerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GenderCell = collectionView.dequeueReusableCell(at: indexPath)
        let gender = genders[indexPath.item]
        
        cell.genderImageView.image = gender.image
        cell.genderLabel.text = gender.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GenderCell {
            cell.isCellSelected = true
        }
        selectedIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GenderCell {
            cell.isCellSelected = false
        }
        selectedIndexPath = nil
    }
  
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? GenderCell,
           cell.isCellSelected {
            
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableHeader(at: indexPath)
        
        let label = UILabel()
        label.font = .roboto(.medium, size: 12)
        label.textColor = .night
        label.text = "Pilih gender kamu"
        
        header.addSubview(label)
        label.anchors.leading.pin()
        label.anchors.centerY.align()
        
        return header
    }
}

// MARK: UICollectionViewDelegate
extension GenderPickerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (bounds.width - 40) / 3, height: 76)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: bounds.width, height: 14)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12, left: 0, bottom: 0, right: 0)
    }
}
