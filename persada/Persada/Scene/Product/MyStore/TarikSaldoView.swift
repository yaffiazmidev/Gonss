//
//  TarikSaldoView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

//protocol TarikSaldoViewDelegate where Self: UIViewController {
//    func navigateToWithdrawBalance()
//}
//
//class TarikSaldoView: UIView {
//
//    var delegate: TarikSaldoViewDelegate?
//
//	let titleLabel: UILabel = {
//		let label = UILabel(text: "Total Saldo", font: .Roboto(.bold, size: 14), textColor: .grey, textAlignment: .left, numberOfLines: 1)
//
//		return label
//	}()
//
//	lazy var tarikSaldoButton: UIButton = {
//        let button = UIButton(title: "Tarik Saldo", titleColor: .secondary, font: .Roboto(.bold, size: 14), backgroundColor: .clear, target: self, action: #selector(handleTarikSaldo(_:)))
//		return button
//	}()
//
//	var saldoLabel: UILabel = {
//		let label = UILabel(text: "0".toMoney(), font: .Roboto(.bold, size: 20), textColor: .black, textAlignment: .left, numberOfLines: 2)
//
//		return label
//	}()
//
//	let saldoPenjualanView: SaldoSellerView = {
//		let view = SaldoSellerView(frame: .zero)
//		view.translatesAutoresizingMaskIntoConstraints = false
//		view.layer.masksToBounds = false
//		view.backgroundColor = .white
//		view.setup(title: .get(.sellerSaldo), saldo: "0".toMoney())
//		view.setupShadow(opacity: 1, radius: 16, offset: CGSize(width: 2, height: 4), color: .whiteSmoke)
//		view.layer.shouldRasterize = true
//		view.layer.rasterizationScale = UIScreen.main.scale
//		view.layer.cornerRadius = 8
//		return view
//	}()
//
//	lazy var saldoRefundView: SaldoSellerView = {
//		let view = SaldoSellerView(frame: .zero)
//		view.translatesAutoresizingMaskIntoConstraints = false
//		view.layer.masksToBounds = false
//		view.backgroundColor = .white
//		view.setup(title: .get(.refundSaldo), saldo: "0".toMoney())
//		view.setupShadow(opacity: 1, radius: 16, offset: CGSize(width: 2, height: 4), color: .whiteSmoke)
//		view.layer.shouldRasterize = true
//		view.layer.rasterizationScale = UIScreen.main.scale
//		view.layer.cornerRadius = 8
//		return view
//	}()
//
//	@objc func handleTarikSaldo(_ sender: UIButton) {
//        self.delegate?.navigateToWithdrawBalance()
//	}
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//
//		backgroundColor = .white
//		addSubview(titleLabel)
//		addSubview(tarikSaldoButton)
//		addSubview(saldoLabel)
//		let stackView = UIStackView(arrangedSubviews: [saldoPenjualanView, saldoRefundView])
//		stackView.translatesAutoresizingMaskIntoConstraints = false
//		stackView.axis = .horizontal
//		stackView.distribution = .fillEqually
//		stackView.spacing = 4
//		addSubview(stackView)
//
//		tarikSaldoButton.anchor(top: safeAreaLayoutGuide.topAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 16, paddingRight: 16, width: 80, height: 20)
//		titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: tarikSaldoButton.leftAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 8, height: 20)
//
//		saldoLabel.anchor(top: titleLabel.bottomAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 13, paddingLeft: 16, paddingRight: 16, height: 30)
//
//		stackView.anchor(top: saldoLabel.bottomAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 24, paddingRight: 16)
//	}
//
//	required init?(coder: NSCoder) {
//		super.init(coder: coder)
//	}
//
//	func configure(total: Int, saldoPenjual: Int, saldoRefund: Int) {
//		saldoLabel.text = total.toMoney()
//		saldoRefundView.saldoLabel.text = saldoRefund.toMoney()
//		saldoPenjualanView.saldoLabel.text = saldoPenjual.toMoney()
//	}
//}

