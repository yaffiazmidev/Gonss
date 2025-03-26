//
//  NoInternetConnectionView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 20/03/24.
//

import UIKit
import KipasKipasShared

class NoInternetConnectionView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var retryImageView: UIImageView!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var handleTapRetryButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    func setupComponent() {
        retryButton.layer.borderWidth = 1
        retryButton.layer.borderColor = UIColor(hexString: "#EEEEEE").cgColor
        retryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        
        retryImageView.image = UIImage.iconRefreshBlack
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    @IBAction func didClickRetryButton(_ sender: Any) {
        handleTapRetryButton?()
    }
    
}
