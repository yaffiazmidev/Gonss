//
//  ShortcutView.swift
//  Persada
//
//  Created by Muhammad Noor on 02/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

private let shortcutId = "shortcutId"

protocol ShortcutViewDelegate where Self: UIViewController {
	func showNews()
	func showFollowing()
}

class ShortcutView: UIView {
	
	// MARK: - Public Property
	
	lazy var collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.dataSource = self
		view.backgroundColor = .white
		view.register(NewSelebShortcutCell.self, forCellWithReuseIdentifier: shortcutId)
		return view
	}()

	var itemsShortcut: [String] = [
		"News", "Following"
	]

	weak var delegate: ShortcutViewDelegate?

	// MARK: - Public Method
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		addSubview(collectionView)
		collectionView.fillSuperviewSafeAreaLayoutGuide()
	}
	
}

extension ShortcutView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return itemsShortcut.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shortcutId, for: indexPath) as! NewSelebShortcutCell

		cell.configure(text: itemsShortcut[indexPath.row])

		switch indexPath.row {

		case 0:
			cell.handleShortcut = { self.delegate?.showNews() }

			return cell
		case 1:
			cell.handleShortcut = { self.delegate?.showFollowing() }

			return cell
		default:
			print("default")
		}
		
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 80, height: 60)
	}
}
