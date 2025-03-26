//
//  ChannelSearchContentController.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChannelSearchContentDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: ChannelSearchContentModel.ViewModel)
}

final class ChannelSearchContentController: UIViewController, Displayable, ChannelSearchContentDisplayLogic {
	
	let mainView: ChannelSearchContentView
	var interactor: ChannelSearchContentInteractable!
	private var router: ChannelSearchContentRouting!
	
	init(mainView: ChannelSearchContentView, dataSource: ChannelSearchContentModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = ChannelSearchContentInteractor(viewController: self, dataSource: dataSource)
		router = ChannelSearchContentRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
        if let channels = ChannelSearchContentSimpleCache.instance.getChannels, !channels.isEmpty {
            interactor.dataSource.data = channels
            mainView.collectionView.reloadData()
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.collectionView.delegate = self
		mainView.collectionView.dataSource = self
		view.backgroundColor = .white
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - ChannelSearchContentDisplayLogic
	func displayViewModel(_ viewModel: ChannelSearchContentModel.ViewModel) {
		DispatchQueue.main.async {
			
			switch viewModel {
			case .channelList(let viewModel):
				self.displaySearchChannel(viewModel)
            case .statusFollow(let viewModel):
                self.displayStatusFollow(viewModel)
			}
		}
	}
}


// MARK: - ChannelSearchContentViewDelegate
extension ChannelSearchContentController: ChannelSearchContentViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		guard let totalData = interactor.dataSource.data?.count else {
			return 0
		}
		
		return totalData
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let totalData = interactor.dataSource.data else {
			return 0
		}
		
		return totalData[section].feeds?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChannelSearchContentView.cellId, for: indexPath) as! ChannelSearchContentItemCell
		
		guard let items = interactor.dataSource.data?[indexPath.section].feeds else {
			return cell
		}
		
		cell.item = items[indexPath.row]
		
		cell.nameLabel.isHidden = true
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let cellforYouChannel = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ChannelSearchContentHeaderView.reuseIdentifier, for: indexPath) as! ChannelSearchContentHeaderView
		
		guard let item = interactor.dataSource.data?[indexPath.section], let isFollow = item.channels?.isFollow else {
			return cellforYouChannel
		}
        
        cellforYouChannel.handleDetailChannel = {
            guard let name = item.channels?.name, let id = item.channels?.id else {
                return
            }
            
            self.router.routeTo(.detailChannel(id: id, name: name))
        }
        
        cellforYouChannel.handleFollow = {
            guard let id = item.channels?.id else {
                return
            }
            
            self.interactor.doRequest(.followChannel(id: id))
        }
		
		cellforYouChannel.configure(post: item.channels)
		
		cellforYouChannel.followButton.isHidden = isFollow
		
		return cellforYouChannel
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let intendedIndex: Int = indexPath.count
        if (intendedIndex >= 0 && indexPath.count >= intendedIndex) {
            guard let channel = self.interactor.dataSource.data?[indexPath.section].channels, let name = channel.name, let id = channel.id, let countryCode = channel.code else {
                return
            }
            
            if countryCode.contains(TikTokCountry.indo.rawValue) ||
                countryCode.contains(TikTokCountry.china.rawValue) ||
                countryCode.contains(TikTokCountry.korea.rawValue) ||
                countryCode.contains(TikTokCountry.thailand.rawValue) {
                let country: TikTokCountry = countryCode == TikTokCountry.indo.rawValue ? .indo : countryCode == TikTokCountry.china.rawValue ? .china : countryCode == TikTokCountry.korea.rawValue ? .korea : .thailand
                router.routeTo(.detailChannel(id: id, name: countryCode))
            }
            
            router.routeTo(.detailChannel(id: id, name: name ))
        }
	}
    
    // TO DO HANDLE HEADER ON CLICK
}


// MARK: - Private Zone
private extension ChannelSearchContentController {
	
	func displaySearchChannel(_ viewModel: [ChannelData]) {
		self.interactor.dataSource.data = viewModel
		mainView.collectionView.reloadData()
	}
    
    
    func displayStatusFollow(_ viewModel: DefaultResponse) {
        NotificationCenter.default.post(name: .notifyReloadChannelSearch, object: nil, userInfo: nil)
    }
}
