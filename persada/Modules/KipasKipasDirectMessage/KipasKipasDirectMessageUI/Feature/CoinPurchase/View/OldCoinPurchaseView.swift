//
//  CoinPurchaseView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 08/08/23.
//

import UIKit
import KipasKipasShared
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase

protocol OldCoinPurchaseViewDelegate: AnyObject {
    func didTapHistoryButton()
    func didTapTnC()
    func didTapBuyNow(product id: String)
//    func didTapBuyCoin()
}

class OldCoinPurchaseView: UIView {
    
    @IBOutlet weak var collectionViewContainer: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var tncLabel: KKDefaultLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputCoinErrorLabel: UILabel!
    @IBOutlet weak var buyNowButton: KKDefaultButton!
    @IBOutlet weak var inputCoinTextField: UITextField!
    @IBOutlet weak var inputCoinContainerStackView: KKDefaultStackView!
    @IBOutlet weak var coinEarnedLabel: UILabel!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            collectionViewHeightConstraint.isActive = true
        }
    }
    
    lazy var historyButton: UIButton = {
        let button = UIButton()
        button.setImage(.get(.icHistoryBlack), for: UIControl.State())
				button.contentMode = .center
				button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: #selector(handleDidTapHistoryButton), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: OldCoinPurchaseViewDelegate?
    
    var coinProducts: [RemoteCoinPurchaseProductData] = [] {
        didSet {
            collectionView.reloadData()
            updateCollectionViewHeight()
        }
    }
    
    var coinInApp: [InAppPurchaseProduct] = [] {
        didSet {
            collectionView.reloadData()
            updateCollectionViewHeight()
        }
    }
    
    var selectedCoinProductId: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(CoinPurchaseCollectionViewCell.self)
        
        inputCoinTextField.delegate = self
        inputCoinTextField.addTarget(self, action: #selector(didEditingChanged(_:)), for: .editingChanged)
        
        buyNowButton.isEnabled = false
        
        tncLabel.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.didTapTnC()
        }
   
        configureUI()
    }
    
    func updateCollectionViewHeight() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.layoutIfNeeded()
        collectionViewHeightConstraint.constant = collectionView.contentSize.height
    }
    
    private func format(double: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.init(identifier: "ID-id")
        formatter.numberStyle = .currency
        if let formatted = formatter.string(from: double as NSNumber) {
            return "\(formatted)"
        }
        return nil
    }
    
    @objc private func handleDidTapHistoryButton() {
        delegate?.didTapHistoryButton()
    }
    
//    @IBAction func didClickBuyCoinButton(_ sender: Any) {
//        delegate?.didTapBuyCoin()
//    }
    
    @IBAction func didClickBuyNowButton(_ sender: Any) {
        if let id = selectedCoinProductId {
            delegate?.didTapBuyNow(product: id)
        }
    }
    
    @objc private func didEditingChanged(_ textField: UITextField) {
        guard let coin = Int(textField.text ?? "") else {
            inputCoinErrorLabel.text = ""
            inputCoinErrorLabel.isHidden = true
            inputCoinContainerStackView.borderColor = UIColor(hexString: "#EEEEEE")
            return
        }
        
        inputCoinErrorLabel.isHidden = coin <= 0 ? false : !(coin > 1000)
        inputCoinErrorLabel.text = coin <= 0 ? "Minimal topup 1 koin" : coin > 1000 ? "Maksimal top up 1000 koin" : ""
        inputCoinContainerStackView.borderColor = UIColor(hexString: inputCoinErrorLabel.isHidden ? "#EEEEEE" : "#E70000")
    }
    
    private func configureUI() {
        topStackView.backgroundColor = .white | .gunMetal
        bottomStackView.backgroundColor = .white | .gunMetal
        collectionViewContainer.backgroundColor = .softPeach | .mirage
        containerView.backgroundColor = .white | .gunMetal
        headingLabel.textColor = .black | .white
        collectionView.backgroundColor = .whiteSnow | .mirage
        buyNowButton.backgroundColor = .watermelon | .secondary
    }
}

extension OldCoinPurchaseView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coinProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CoinPurchaseCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        
        let data = coinProducts[indexPath.item]
        let valid = coinInApp.contains(where: { $0.productIdentifier == data.storeProductId })
        let selected = data.storeProductId == selectedCoinProductId
        
        cell.configure(with: data)
        // cell.contentView.backgroundColor = valid ? .clear : .gray.withAlphaComponent(0.3)
        
        
        cell.contentView.backgroundColor = valid ? .white | .mirage : .gray.withAlphaComponent(0.3)
        
        let lightBorderColor = UIColor(hexString: "#4CA0F8")
        let darkBorderColor = UIColor.boulder
        let adaptiveBorderColor = lightBorderColor | darkBorderColor
        
        cell.layer.borderWidth = selected ? 1.5 : 0
        cell.layer.borderColor = selected ? adaptiveBorderColor.cgColor : UIColor.clear.cgColor
        
        cell.isUserInteractionEnabled = valid
        return cell
    }
}

extension OldCoinPurchaseView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 3) - 1.4, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedData = coinProducts[indexPath.item]
        selectedCoinProductId = selectedData.storeProductId
        
        buyNowButton.isEnabled = true
        
        coinEarnedLabel.text = "\(selectedData.qtyPerPackage ?? 0)"
        coinPriceLabel.text = format(double: selectedData.price ?? 0)
        totalPaymentLabel.text = format(double: selectedData.price ?? 0)
        
        collectionView.reloadData()
    }
}

extension OldCoinPurchaseView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == "0" {
            return false
        }
        
        let maxLength = 4
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        return newLength <= maxLength
    }
}
