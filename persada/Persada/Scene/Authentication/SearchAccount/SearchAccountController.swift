//
//  SearchAccountController.swift
//  Persada
//
//  Created by Muhammad Noor on 22/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

private let cellId: String = "cellId"

class SearchAccountController: UIViewController {
    
    let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        
        return search
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: "Hasil pencarian", font: .systemFont(ofSize: 12), textColor: .lightGray, textAlignment: .center, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    let collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(FollowArtistCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    let navigationBottom: NavigationBottomView = {
        let navigation = NavigationBottomView()
        navigation.translatesAutoresizingMaskIntoConstraints = false
        return navigation
    }()
    
    private var viewModel: SearchAccountViewModel?
    private var artists: [ContentArtist] = []
    private var filterArtists: [ContentArtist] = []
    private var tempParameter: Parameter? = []
    var timer = Timer()
    
    convenience init(viewModel: SearchAccountViewModel) {
        self.init()
        
        self.viewModel = viewModel
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindViewModel()
        bindCollectionView()
    }
    
    func bindViewModel() {
        viewModel?.changeHandler = { [weak self] change in
            
            guard let self = self else {
                return
            }
            
            switch change {
                case .didEncounterError(let error):
                    print("error \(error?.statusMessage ?? "")")
                case .didUpdateFollowArtistUser(let response):
                    
                    self.artists = response
                    self.filterArtists = self.artists
                    DispatchQueue.main.async {
                        if response.count != 0 {
                            self.titleLabel.text = "Hasil pencarian \(self.viewModel?.searchText ?? "")"
                        } else {
                            self.titleLabel.text = "Hasil pencarian \(self.viewModel?.searchText ?? "") tidak ditemukan"
                        }
                        self.collectionView.reloadData()
                }
            }
        }
        
        viewModel?.inputHandler = { [weak self] change in
            
            guard let self = self else {
                return
            }
            
            switch change {
            case .didEncounterError(let error):
                print("error \(error?.statusMessage ?? "")")
            case .didPushNavigation:
                DispatchQueue.main.async {
                    self.clearNotifsNav()
                    let mainTabController = MainTabController()
                    mainTabController.modalPresentationStyle = .fullScreen
                    self.present(mainTabController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func clearNotifsNav(){
       if let tab = self.view.window?.rootViewController, tab is MainTabController {
            let mainTab = tab as? MainTabController
            mainTab?.notifsNavigate?.cleanNotif()
            mainTab?.notifsNavigate = nil
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.becomeFirstResponder()
        definesPresentationContext = true
        
        view.addSubview(searchBar)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(navigationBottom)
        
        navigationBottom.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 64)
        
        navigationBottom.nextClosure = {
            if let limitParameter = self.tempParameter?.count, limitParameter > 0 {
                
                let param = try? JSONEncoder().encode(self.tempParameter)
                let temp = String(data: param!, encoding: .utf8)
                
                self.viewModel?.parameters = temp
                self.viewModel?.inputArtists()
            }
        }
        
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 14, paddingLeft: 31, paddingBottom: 0, paddingRight: 31, width: 0, height: 50)
        
        titleLabel.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 20)
    }
    
    func bindCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: navigationBottom.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 34, paddingBottom: 0, paddingRight: 34, width: 0, height: 0)
    }
}

// MARK:- UISearchBarDelegate, UISearchResultsUpdatingb & UISearchControllerDelegate

extension SearchAccountController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate  {
    
    @objc func handleSearchText() {
        self.viewModel?.searchArtist()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer.invalidate()
        self.viewModel?.searchText = searchBar.text
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleSearchText), userInfo: searchText, repeats: false)
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension SearchAccountController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 5, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FollowArtistCell
        cell.data = self.filterArtists[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellId = self.viewModel?.getCellViewModel(at: indexPath.item)?.id else {
            return
        }
        
        tempParameter?.append(ParameterChannel(id: cellId))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cellId = self.viewModel?.getCellViewModel(at: indexPath.item)?.id, let index = tempParameter?.firstIndex(where: { return $0.id == cellId }) else {
            return
        }
        
        tempParameter?.remove(at: index)
    }
}

