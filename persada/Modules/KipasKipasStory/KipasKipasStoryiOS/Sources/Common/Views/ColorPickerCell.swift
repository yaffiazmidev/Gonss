import UIKit
import KipasKipasShared

final class ColorPickerCell: UICollectionViewCell {
    
    let colorView = UIView()
    
    var isCellSelected: Bool = false {
        didSet {
            isSelected = isCellSelected
            setSelected()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = colorView.bounds.height / 2
    }
    
    private func setSelected() {
        if isCellSelected {
            UIView.animate(withDuration: 0.2) {
                self.colorView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.colorView.transform = .identity
            }
        }
    }
}

// MARK: UI
private extension ColorPickerCell {
    func configureUI() {
        configureColorView()
    }
    
    func configureColorView() {
        colorView.clipsToBounds = true
        colorView.layer.borderWidth = 1.5
        colorView.layer.borderColor = UIColor.white.cgColor
        
        addSubview(colorView)
        colorView.anchors.edges.pin()
    }
}
