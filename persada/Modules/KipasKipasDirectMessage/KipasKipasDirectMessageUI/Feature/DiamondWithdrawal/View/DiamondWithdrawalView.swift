//
//  DiamondWithdrawalView.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit

protocol DiamondWithdrawalViewDelegate: AnyObject {
    func didTapTnC()
    func didTapHistoryButton()
    func didTapWithdrawalButton()
    func currencyConverter(with value: Int)
    func didTapBank()
}

class DiamondWithdrawalView: UIView {
    @IBOutlet weak var topTypeLabel: UILabel!
    @IBOutlet weak var withdrawalButton: KKDefaultButton!
    @IBOutlet weak var tncLabel: UILabel!
    @IBOutlet weak var inputDiamondTextField: UITextField!
    @IBOutlet weak var inputDiamondContainerStackView: KKDefaultStackView!
    @IBOutlet weak var inputDiamondErrorLabel: UILabel!
    @IBOutlet weak var myDiamondLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var diamondWithdrawalLabel: UILabel!
    @IBOutlet weak var withdrawalAmountLabel: UILabel!
    @IBOutlet weak var bankStackView: UIStackView!
    @IBOutlet weak var nameBankLabel: UILabel!
    @IBOutlet weak var norekLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var withdrawalFeeLabel: UILabel!
    @IBOutlet weak var errorNameBankLabel: UILabel!
    @IBOutlet weak var norekStackView: UIStackView!
    @IBOutlet weak var totalWithdrawalLabel: UILabel!
    
    lazy var historyButton: UIButton = {
        let button = UIButton()
        button.setImage(.get(.icHistoryBlack), for: UIControl.State())
				button.contentMode = .center
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: #selector(handleDidTapHistoryButton), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: DiamondWithdrawalViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        handleTapTnC()
        handleInputDiamondTextField()
        bankStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapBank()
        }
    }
    
    private func handleInputDiamondTextField() {
        inputDiamondTextField.delegate = self
        inputDiamondTextField.addTarget(self, action: #selector(didEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc func didEditingChanged(_ textField: UITextField) {
        
        guard let diamond = Int(textField.text ?? "") else {
            handleErrorInputDiamond(isError: false, title: "")
            return
        }
        
        let myDiamond = Int(myDiamondLabel.text ?? "") ?? 0
        
        guard diamond <= myDiamond else {
            handleErrorInputDiamond(isError: true, title: "Penarikan diamond tidak bisa dilakukan karena melebihi diamond yang kamu miliki")
            return
        }
        
        inputDiamondErrorLabel.isHidden = diamond < 500 ? false : !(diamond > 100_000)
        inputDiamondErrorLabel.text = diamond < 500 ? "Minimal penarikan 500 diamond" : diamond > 100_000 ? "Maksimal 100.000 diamond dalam 1 penarikan" : ""
        inputDiamondContainerStackView.borderColor = UIColor(hexString: inputDiamondErrorLabel.isHidden ? "#EEEEEE" : "#E70000")
        let emptyWithdrawalFee = withdrawalFeeLabel.text?.contains("-Rp 0") == true
        let isEnableWithdrawButton = inputDiamondErrorLabel.isHidden && diamond != 0 && !emptyWithdrawalFee
        withdrawalButton.backgroundColor = UIColor(hexString: isEnableWithdrawButton ? "#FF4265" : "#F2A8B6")
        withdrawalButton.isEnabled = isEnableWithdrawButton
        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
            self.delegate?.currencyConverter(with: diamond)
        }
    }
    
    private func handleErrorInputDiamond(isError: Bool, title: String) {
        inputDiamondErrorLabel.isHidden = !isError
        inputDiamondErrorLabel.text = title
        inputDiamondContainerStackView.borderColor = UIColor(hexString: !isError ? "#EEEEEE" : "#E70000")
    }
    
    private func handleTapTnC() {
        tncLabel.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.didTapTnC()
        }
    }
    
    @objc private func handleDidTapHistoryButton() {
        delegate?.didTapHistoryButton()
    }
    
    @IBAction func didClickWithdrawalButton(_ sender: Any) {
        delegate?.didTapWithdrawalButton()
    }
}

extension DiamondWithdrawalView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == "0" {
            return false
        }
        
        let maxLength = 6
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        return newLength <= maxLength
    }
}

