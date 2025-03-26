import UIKit
import KipasKipasShared

protocol ColorPickerDelegate: AnyObject {
    func didSelectColor(_ color: UIColor?)
}

final class ColorPickerCollectionView: UICollectionView {
    
    weak var colorDelegate: ColorPickerDelegate?
    
    private var selectedIndexPath: IndexPath? {
        didSet {
            if let selectedIndexPath {
                colorDelegate?.didSelectColor(colors[selectedIndexPath.item])
            }
        }
    }
    
    private var colors: [UIColor] = [
        UIColor(hexString: "#FFFFFF"),
        UIColor(hexString: "#000000"),
        UIColor(hexString: "#EA4141"),
        UIColor(hexString: "#FF933D"),
        UIColor(hexString: "#F2CD44"),
        UIColor(hexString: "#78C35E"),
        UIColor(hexString: "#76C9A6"),
        UIColor(hexString: "#3696F1"),
        UIColor(hexString: "#2544B1"),
        UIColor(hexString: "#5756D4"),
        UIColor(hexString: "#F9D7EA")
    ]
    
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UICollectionViewDataSource & UICollectionViewDelegate
extension ColorPickerCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ColorPickerCell = collectionView.dequeueReusableCell(at: indexPath)
        cell.colorView.backgroundColor = colors[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorPickerCell {
            cell.isCellSelected = true
        }
        selectedIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorPickerCell {
            cell.isCellSelected = false
        }
        selectedIndexPath = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 25, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
}

// MARK: UI
private extension ColorPickerCollectionView {
    func configureUI() {
        configureCollectionView()
    }
    
    func configureCollectionView() {
        contentInset.left = 12
        contentInset.right = 12
        
        backgroundColor = .clear
        delegate = self
        dataSource = self
        decelerationRate = .fast
        showsHorizontalScrollIndicator = false
        setCollectionViewLayout(layout, animated: true)
        
        registerCell(ColorPickerCell.self)
    }
}
