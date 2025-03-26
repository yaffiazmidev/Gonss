//
//  ComplaintConfirmController.swift
//  KipasKipas
//
//  Created by NOOR on 02/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ComplaintConfirmController: UIViewController, UIGestureRecognizerDelegate {
	
	var imageView: UIImageView = UIImageView()
	
	var titleLabel: UILabel = UILabel(text: "Komplain kamu berhasil dikirim", font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)
	var subtitleLabel: UILabel = UILabel(text: "Laporan akan diproses dalam waktu 2 x 24 jam. Kami akan menghubungi kamu melalui direct message", font: .Roboto(.regular, size: 12), textColor: .grey, textAlignment: .center, numberOfLines: 0)
    
    var nominalLabel: UILabel = UILabel(text: "Rp 1.200.000", font: .Roboto(.bold, size: 12), textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    var fromRefund = false
    var nominal = 0
    
	lazy var trackingButton = PrimaryButton(
		title: "Detail Transaksi",
		titleColor: .white,
		font: .Roboto(.bold, size: 14),
		backgroundColor: .primary,
		target: self,
		action: #selector(handleConfirm)
	)
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		tabBarController?.tabBar.isHidden = true
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationItem.setHidesBackButton(true, animated: true)
        if fromRefund {
            navigationItem.title = .get(.pengembalianDana)
        } else {
            navigationItem.title = .get(.sendComplaint)
        }
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(trackingButton)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(subtitleLabel)
        view.addSubview(nominalLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: .get(.iconConfirm))
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 40
        
        imageView.anchor(bottom: titleLabel.topAnchor, paddingBottom: 12, width: 50, height: 50)
        titleLabel.centerXTo(view.centerXAnchor)
        titleLabel.centerYTo(view.centerYAnchor)
        imageView.centerXTo(view.centerXAnchor)
        titleLabel.anchor(paddingLeft: 48, paddingBottom: 8, paddingRight: 48)
        trackingButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20)
        nominalLabel.isHidden = true
        if fromRefund {
            nominalLabel.isHidden = false
            subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 48, paddingRight: 48)
        
            nominalLabel.anchor(top: subtitleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 48, paddingRight: 48)
            nominalLabel.text = nominal.toMoney()
            titleLabel.text = "Pengembalian dana berhasil"
            subtitleLabel.text = "Nominal Pengembalian"
            trackingButton.text("Kembali ke My Shop")
        } else {
            
            subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 48, paddingRight: 48)
        }
	}
	
	@objc func handleConfirm() {
//        if fromRefund {
//            print("Go To My Shop")
//        }
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }

        for detailTransactionController in viewControllers {
            if detailTransactionController is DetailTransactionPurchaseController {
                self.navigationController?.popToViewController(detailTransactionController, animated: true)
                break
            }
        }
	}
}

