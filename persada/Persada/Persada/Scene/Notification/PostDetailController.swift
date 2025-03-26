//
//  PostDetailController.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine

class PostDetailController: UIViewController, UIGestureRecognizerDelegate {
	
	private var subscriptions = Set<AnyCancellable>()
	lazy var postView: PostDetailView = {
		let view = PostDetailView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		bindNavigationBar()
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(postView)
		postView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), size: CGSize(width: view.frame.width - 16, height: 400))
	}
	
	@objc func onClickBack()
	{
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	private func bindNavigationBar() {
		let btnLeftMenu: UIButton = UIButton()
		btnLeftMenu.setImage(UIImage(named: "arrowleft"), for: UIControl.State())
		btnLeftMenu.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
		btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33/2, height: 27/2)
		let barButton = UIBarButtonItem(customView: btnLeftMenu)
		self.navigationItem.leftBarButtonItem = barButton
	}
	
	func fetchUsername(id: String) {
		let network = FeedNetworkModel()
		
		network.PostDetail(.postDetail(id: id)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		}) { (model: PostDetailResult) in
			DispatchQueue.main.async {
				
				guard let item = model.data else {
					return
				}
				self.postView.configureItem(item)
				self.postView.configureMedias(item.post?.medias ?? [])
			}
		}.store(in: &subscriptions)
	}

}
