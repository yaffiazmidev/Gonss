//
//  VirtualAccountNumberView.swift
//  KipasKipas
//
//  Created by movan on 19/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol VirtualAccountNumberViewDelegate where Self: UIViewController {
	
	func dismiss()
}

final class VirtualAccountNumberView: UIView {
	
	weak var delegate: VirtualAccountNumberViewDelegate?
	
	private enum ViewTrait {
		static let padding: CGFloat = 16.0
	}
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "Lakukan Pembayaran Dalam"
		label.font = UIFont.Roboto(.regular, size: 16)
		label.textAlignment = .center
		label.textColor = .contentGrey
		return label
	}()
	
	lazy var virtualAccountView: VirtualAccountView = {
		let view = VirtualAccountView()
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 16
		view.setupShadow(opacity: 1, radius: 16, offset:
			CGSize(width: 2, height: 4), color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1))
		
		return view
	}()
	
	lazy var countDownLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .contentGrey
		label.font = UIFont.Roboto(.regular, size: 25)
		return label
	}()

	lazy var guidelineLabel: UILabel = {
		let label: UILabel = UILabel()
		label.font = UIFont.Roboto(.regular, size: 12)
		label.textColor = .black
		label.numberOfLines = 0
		label.text = String.get(.caraBayarStep)
		return label
	}()
	
	lazy var confirmButton: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Detail Transaksi", for: .normal)
		button.setup(color: .primary, textColor: .white, font: UIFont.Roboto(.bold, size: 16))
		button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
		button.layer.cornerRadius = 8
		return button
	}()
	
	lazy var caraBayarLabel : UILabel = {
		let label : UILabel = UILabel()
		label.font = UIFont.Roboto(.regular, size: 12)
		label.textColor = .black
		label.text = String.get(.caraBayar)
		return label
	}()
	
	deinit {
		timer.invalidate()
	}
	
	@objc func handleButton() {
		self.delegate?.dismiss()
	}
	var count = 300
	var timer = Timer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		
		
		[titleLabel, countDownLabel, virtualAccountView, guidelineLabel, confirmButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.layer.masksToBounds = false
			addSubview($0)
		}
		
//		virtualAccountView.numberLabel.text = "6430-0231-6476-5415"
//		virtualAccountView.titleLabel.text = "Ke BCA Virtual Account"

		titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 40, height: 24)
		countDownLabel.anchor(top: titleLabel.bottomAnchor, paddingTop: 12, paddingLeft: 20, paddingRight: 20)
		countDownLabel.centerXTo(centerXAnchor)
		
		virtualAccountView.anchor(top: countDownLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 145)
		guidelineLabel.anchor(top: virtualAccountView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 24, paddingLeft: 21, paddingRight: 21, height: 278)
		confirmButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 48)
	}
	
	func setData(accountNumber : String, bankName : String, time: Int){
		virtualAccountView.numberLabel.text = accountNumber
		virtualAccountView.titleLabel.text = "ke \(bankName.uppercased()) Virtual Account"
        count = Int(Float(time - Int(getCurrentMillis())) / 1000.0)
		print("CUR MILLIS \(getCurrentMillis())")
		print("CUR MILLIS time \(time)")
		print("CUR MILLIS count \(count)")
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	@objc func update() {
		if(count > 0) {
			count = count - 1
			countDownLabel.text = timeString(time: TimeInterval(count))
		} else if ( count == 0) {
			timer.invalidate()
		} else {
			timer.invalidate()
			
			countDownLabel.text = "00:00:00"
		}
		
	}
	
	
	func getCurrentMillis()->Int64 {
			return Int64(Date().timeIntervalSince1970 * 1000)
	}

	func timeString(time: TimeInterval) -> String {
			let hours = Int(time) / 3600
			let minutes = Int(time) / 60 % 60
			let seconds = Int(time) % 60
			return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
	}
}

class VirtualAccountView: UIView {
	
	var handler: (() -> Void)?
	
	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.font = UIFont.Roboto(.bold, size: 16)
		label.textColor = .placeholder
		label.backgroundColor = .white
		label.textAlignment = .center
		
		return label
	}()
	
	lazy var numberLabel: UILabel = {
		let label: UILabel = UILabel()
		label.font = UIFont.Roboto(.regular, size: 18)
		label.textColor = .contentGrey
		label.backgroundColor = .secondaryLowTint
		label.textAlignment = .center
		return label
	}()
	
	lazy var copyButton: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.setTitle("Salin", for: .normal)
		button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
		button.setup(color: .white, textColor: .secondary, font: UIFont.Roboto(.bold, size: 16))
		button.layer.cornerRadius = 0
		return button
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[titleLabel, numberLabel, copyButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.layer.masksToBounds = false
			$0.constrainHeight(45)
			addSubview($0)
		}
		
		titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0)
		numberLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0)
		
		copyButton.anchor(top: numberLabel.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handleButton() {
		self.handler?()
	}
}
