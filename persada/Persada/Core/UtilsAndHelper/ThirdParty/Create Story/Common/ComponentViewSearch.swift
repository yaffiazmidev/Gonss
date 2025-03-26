//
//  ComponentViewSearch.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ComponentViewSearch: UIView {
		
		private let txt = UITextField()
		private let imgView = UIImageView()
		private var actionSearch : (String) -> () = {_ in}
		private var searchTimer : Timer = Timer()
		
		override init(frame: CGRect) {
				super.init(frame: frame)
				backgroundColor = UIColor.white
				layer.borderWidth = 0.5
				layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
				layer.cornerRadius = 8
				translatesAutoresizingMaskIntoConstraints = false
				
				imgView.image = UIImage(named: .get(.iconSearch))?.withRenderingMode(.alwaysTemplate)
				imgView.translatesAutoresizingMaskIntoConstraints = false
				imgView.tintColor = .gray
				addSubview(imgView)
				
				txt.font = .systemFont(ofSize: 14, weight: .medium)
				txt.textColor = .black
				txt.translatesAutoresizingMaskIntoConstraints = false
				txt.delegate = self
//				txt.placeholder = "Cari Produk.."
				
            txt.attributedPlaceholder = NSAttributedString(string: .get(.cariProduk),
																			 attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
				addSubview(txt)
				
				NSLayoutConstraint.activate([
						imgView.centerYAnchor.constraint(equalTo: centerYAnchor),
						imgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
						imgView.heightAnchor.constraint(equalToConstant: 16),
						imgView.widthAnchor.constraint(equalToConstant: 16),
						txt.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
						txt.topAnchor.constraint(equalTo: topAnchor),
						txt.trailingAnchor.constraint(equalTo: imgView.leadingAnchor, constant: -16),
						txt.bottomAnchor.constraint(equalTo: bottomAnchor)
				])
		}
		
		required init?(coder: NSCoder) {
				super.init(coder: coder)
		}
		
		func setupView(
				_ pcholder: String) -> ComponentViewSearch {
				txt.placeholder = pcholder
				return self
		}
		
		func addComponent(_ superView: UIView) -> ComponentViewSearch {
				superView.addSubview(self)
				return self
		}
		
		func setupSearch(_ action: @escaping (String)->()) -> ComponentViewSearch {
				actionSearch = action
				txt.addTarget(self, action: #selector(didChangeValue(_:)), for: .editingChanged)
				return self
		}
		
}

extension ComponentViewSearch: UITextFieldDelegate{
		@objc private func didChangeValue(_ txt: UITextField){
				searchTimer.invalidate()
				searchTimer = Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(fireTime), userInfo: nil, repeats: false)
		}
		
		func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			 searchTimer.invalidate()
			 fireTime()
			 return true
		}
		
		@objc private func fireTime(){
				actionSearch(txt.text ?? "")
		}
}
