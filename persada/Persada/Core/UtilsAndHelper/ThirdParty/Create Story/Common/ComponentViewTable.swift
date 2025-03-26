//
//  ComponentViewTable.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ComponentViewTable: UITableView {
		
		private var numSection : () -> (Int) = { return 0 }
		private var numRow : (Int) -> (Int ) = { _ in return 0}
		private var setupRow : (UITableView, IndexPath) -> (UITableViewCell) = {_,_  in return UITableViewCell()}
		private var actionDidSelect : (IndexPath) -> () = {_ in}
		private var didScroll : () -> () = {}
		
		override init(frame: CGRect, style: UITableView.Style) {
				super.init(frame: frame, style: style)
				translatesAutoresizingMaskIntoConstraints = false
		}
		
		required init?(coder: NSCoder) {
				super.init(coder: coder)
		}
		
		func addComponent(_ superView: UIView) -> ComponentViewTable {
				superView.addSubview(self)
				return self
		}
		
		func setupView(
				_ background: UIColor = .white,
				_ separator : UITableViewCell.SeparatorStyle,
				_ estimatedHeight: CGFloat) -> ComponentViewTable {
				backgroundColor = background
				separatorStyle  = separator
				rowHeight       = UITableView.automaticDimension
				estimatedRowHeight = estimatedHeight
				return self
		}
		
		func setupInset(inset: UIEdgeInsets) -> ComponentViewTable {
				contentInset = inset
				return self
		}
		
		func setupDelegate(registerCellNib: [String],
											 totalSection: @escaping ()->(Int),
											 totalRowSection: @escaping (Int)->(Int),
											 setupCell: @escaping (UITableView, IndexPath)->(UITableViewCell),
											 actionSelect: @escaping(IndexPath)->(),
											 didScrol: @escaping()->()) -> ComponentViewTable {
				for c in registerCellNib{
						register(UINib(nibName: c, bundle: nil), forCellReuseIdentifier: c)
				}
				delegate   = self
				dataSource = self
				numSection      = totalSection
				numRow          = totalRowSection
				setupRow        = setupCell
				actionDidSelect = actionSelect
				didScroll       = didScrol
				return self
		}
		
}

extension ComponentViewTable: UITableViewDelegate, UITableViewDataSource{
		
		func numberOfSections(in tableView: UITableView) -> Int {
				numSection()
		}
		
		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
				numRow(section)
		}
		
		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
				setupRow(tableView, indexPath)
		}
		
		func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
				actionDidSelect(indexPath)
		}
		
}

extension ComponentViewTable: UIScrollViewDelegate{
		
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
				didScroll()
		}
		
}
