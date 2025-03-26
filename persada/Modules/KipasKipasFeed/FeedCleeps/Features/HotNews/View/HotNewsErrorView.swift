//
//  HotNewsErrorView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/03/24.
//

import UIKit
import KipasKipasShared

protocol HotNewsErrorViewDelegate: AnyObject {
    func didTapButton()
}

class HotNewsErrorView: UIView {
    // MARK: Variable
    weak var delegate: HotNewsErrorViewDelegate?
    var message: String = "" {
        didSet {
            label.text = message
        }
    }
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        return view
    }()
    
    lazy var button: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.setTitle("Coba Lagi", for: .normal)
        view.setTitleColor(.white, for: .normal)
        return view
    }()
    
    
    // MARK: Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

private extension HotNewsErrorView {
    func configUI() {
        backgroundColor = .black
        
        addSubviews([label, button])
        
        button.anchors.height.equal(50)
        button.anchors.width.equal(200)
        button.anchors.centerX.equal(anchors.centerX)
        button.anchors.bottom.equal(safeAreaLayoutGuide.anchors.bottom, constant: -72)
        
        label.anchors.leading.equal(anchors.leading, constant: 32)
        label.anchors.trailing.equal(anchors.trailing, constant: -32)
        label.anchors.bottom.equal(button.anchors.top, constant: -32)
        
        button.onTap { [weak self] in
            self?.delegate?.didTapButton()
        }
    }
}
