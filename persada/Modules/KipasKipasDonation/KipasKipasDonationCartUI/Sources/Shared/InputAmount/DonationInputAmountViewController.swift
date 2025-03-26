//
//  DonationInputAmountViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/03/23.
//

import UIKit
import KipasKipasShared

public enum DonationInputAmountType {
    case add
    case update
    case now
}

public class DonationInputAmountViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeIconContainerView: UIStackView!
    @IBOutlet weak var donationButton: UIButton!
    @IBOutlet weak var donationAmountTextField: UITextField!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var nominalAvailable1: UIView!
    @IBOutlet weak var nominalAvailable2: UIView!
    @IBOutlet weak var nominalAvailable3: UIView!
    @IBOutlet weak var nominalAvailable4: UIView!
    @IBOutlet weak var termsConditionLabel: UILabel!
    
    public var handleCreateOrderDonation: ((Double) -> Void)?
    var donationAmount: Double = 0.0
    public var donationType: DonationInputAmountType = .now {
        didSet {
            updateDonationWording()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        mainView.layer.cornerRadius = 16
        mainView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        donationAmountTextField.delegate = self
        donationAmountTextField.addTarget(self, action: #selector(didValueChange(_:)), for: .editingChanged)
        
        setupTermsCondition()
        
        fadeView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleDismiss()
        }
        
        closeIconContainerView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleDismiss()
        }
        
        nominalAvailable1.onTap { [weak self] in
            guard let self = self else { return }
            self.selectNominal(amount: 10000)
        }
        
        nominalAvailable2.onTap { [weak self] in
            guard let self = self else { return }
            self.selectNominal(amount: 25000)
        }
        
        nominalAvailable3.onTap { [weak self] in
            guard let self = self else { return }
            self.selectNominal(amount: 50000)
        }
        
        nominalAvailable4.onTap { [weak self] in
            guard let self = self else { return }
            self.selectNominal(amount: 100000)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.fadeView.alpha = 1
            }
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "shouldResumePlayer"), object: nil)
        }
    }
    
    public init() {
        super.init(nibName: "DonationInputAmountViewController", bundle: Bundle(for: DonationInputAmountViewController.self))
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func selectNominal(amount: Double) {
        donationAmountTextField.text = nil
        view.endEditing(true)
        donationAmount = amount
        donationButton.isEnabled = true
        donationButton.setBackgroundColor(.primary, forState: .normal)
        nominalAvailable1.backgroundColor = UIColor.init(hexString: amount == 10000 ? "E7F3FF" : "F9F9F9")
        nominalAvailable2.backgroundColor = UIColor.init(hexString: amount == 25000 ? "E7F3FF" : "F9F9F9")
        nominalAvailable3.backgroundColor = UIColor.init(hexString: amount == 50000 ? "E7F3FF" : "F9F9F9")
        nominalAvailable4.backgroundColor = UIColor.init(hexString: amount == 100000 ? "E7F3FF" : "F9F9F9")
    }
    
    private func setupTermsCondition() {
        let fullText = "Pelajari selengkapnya tentang Syarat & Ketentuan"
        let linkText = "Syarat & Ketentuan"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: linkText)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.secondary, range: range)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        
        termsConditionLabel.attributedText = attributedString
        termsConditionLabel.isUserInteractionEnabled = true
        termsConditionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClikTermsCondition)))
    }
    
    @objc func didClikTermsCondition(_ gesture: UITapGestureRecognizer) {
        guard let text = termsConditionLabel.attributedText?.string else { return }
        
        let linkText = "Syarat & Ketentuan"
        let range = (text as NSString).range(of: linkText)
        
        if gesture.didTapAttributedTextInLabel(label: termsConditionLabel, inRange: range) {           
            let url = "https://kipaskipas.com/syarat-dan-ketentuan-kipaskipas/"
            let browserController = BrowserController(url: url, type: .general)
            self.present(browserController, animated: true)
        }
    }
    
    private func handleDismiss() {
        fadeView.alpha = 0
        dismiss(animated: true)
    }
    
    @objc private func didValueChange(_ textField: UITextField) {
        guard let amount = textField.text, !amount.isEmpty else { return }
        
        donationAmountTextField.text = amount.digits().toMoney(withCurrency: false)
        
        let donationAmount = Double(Int(donationAmountTextField.text?.digits() ?? "0") ?? 0)
        self.donationAmount = donationAmount
        donationButton.isEnabled = donationAmount >= 10000
        donationButton.setBackgroundColor(donationAmount >= 10000 ? .primary : .primaryDisabled, forState: .normal)
    }
    
    @IBAction func didClickDonationButton(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.handleCreateOrderDonation?(self.donationAmount)
            }
        }
    }
    
    private func updateDonationWording() {
        var titleText = ""
        var buttonText = ""
        switch donationType {
        case .add:
            titleText = "Tentukan Jumlah Donasi"
            buttonText = "+ Tambahkan ke Keranjang Donasi"
        case .update:
            titleText = "Ubah Jumlah Donasi"
            buttonText = "Simpan Perubahan Jumlah Donasi"
        case .now:
            titleText = "Tentukan Jumlah Donasi"
            buttonText = "Donasikan Sekarang"
        }
        
        titleLabel.text = titleText
        donationButton.setTitle(buttonText)
        donationButton.setBackgroundColor(donationAmount >= 10000 ? .primary : .primaryDisabled, forState: .normal)
    }
}

extension DonationInputAmountViewController: UITextFieldDelegate {
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        donationButton.isEnabled = false
        donationButton.backgroundColor = .primaryDisabled
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        donationButton.isEnabled = false
        donationButton.setBackgroundColor(.primaryDisabled, forState: .normal)
        nominalAvailable1.backgroundColor = UIColor.init(hexString: "F9F9F9")
        nominalAvailable2.backgroundColor = UIColor.init(hexString: "F9F9F9")
        nominalAvailable3.backgroundColor = UIColor.init(hexString: "F9F9F9")
        nominalAvailable4.backgroundColor = UIColor.init(hexString: "F9F9F9")
    }
}
