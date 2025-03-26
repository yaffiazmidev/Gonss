//
//  NotificationSuggestionInfoView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 03/05/24.
//

import UIKit

protocol NotificationSuggestionInfoViewDelegate: AnyObject {
    func didClose()
}

class NotificationSuggestionInfoView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeContainerStackView: UIStackView!
    
    weak var delegate: NotificationSuggestionInfoViewDelegate?
    
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
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupComponent() {
        overrideUserInterfaceStyle = .light
        setDescriptionLabelAttributeLabel()
        closeContainerStackView.isUserInteractionEnabled = true
        let onTapCloseIconGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapCloseIcon))
        closeContainerStackView.addGestureRecognizer(onTapCloseIconGesture)
    }
    
    @objc func handleOnTapCloseIcon() {
        delegate?.didClose()
    }
    
    func setDescriptionLabelAttributeLabel() {
        let regularText1 = "Akun disarankan berdasarkan minat dan koneksi Anda. Akun Anda mungkin juga disarankan kepada orang yang mungkin Anda kenal. Anda dapat mengubah kemampuan untuk ditemukan kapan saja dengan "
        let boldText1 = "menyarankan akun Anda kepada orang lain "
        let regularText2 = "dari " + "\"" + "Pengaturan dan privasi" + "\"" + ". "
        let boldText2 = "\nPelajari Lebih Lajut"

        // Menggabungkan string dengan atribut berbeda
        let regularText1AttributedString = NSMutableAttributedString(
            string: regularText1
        )
        
        let attributedStringBoldText1 = NSMutableAttributedString(
            string: boldText1,
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        )
        
        let regularText2AttributedString = NSAttributedString(
            string: regularText2
        )
        
        let attributedStringBoldText2 = NSMutableAttributedString(
            string: boldText2,
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        )

        // Menggabungkan atribut string ke satu
        regularText1AttributedString.append(attributedStringBoldText1)
        regularText1AttributedString.append(regularText2AttributedString)
//        regularText1AttributedString.append(attributedStringBoldText2)

        // Menetapkan atribut string ke label
        descriptionLabel.attributedText = regularText1AttributedString
    }
}

