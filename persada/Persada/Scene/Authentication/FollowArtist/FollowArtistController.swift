//
//  FollowArtistController.swift
//  Persada
//
//  Created by Muhammad Noor on 22/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

private let cellId: String = "cellId"

class FollowArtistController: UIViewController {
    
    // MARK:- Public Property
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: "Ikuti minimal satu akun sosial media yang kamu sukai.", font: .boldSystemFont(ofSize: 18), textColor: .black, textAlignment: .center, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Cari idol kamu"
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.backgroundColor = .init(hexString: "#FAFAFA")
        textField.addTarget(self, action: #selector(handleTappedSearchTextField), for: .touchDown)
        return textField
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
    
    private var viewModel: FollowArtistViewModel?
    private var artists: [ContentArtist] = []
    private var filterArtists: [ContentArtist] = []
    private var tempParameter: Parameter? = []
    
    // MARK:- Public Method
    
    convenience init(viewModel: FollowArtistViewModel) {
        self.init()
        
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        filterArtists = artists

        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(navigationBottom)
        view.addSubview(collectionView)
        
        navigationBottom.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 64)
        
        navigationBottom.backClosure = {
            self.navigationController?.popViewController(animated: true)
        }
        
        navigationBottom.nextClosure = {
            if let limitParameter = self.tempParameter?.count, limitParameter > 0 {
                
                let param = try? JSONEncoder().encode(self.tempParameter)
                let temp = String(data: param!, encoding: .utf8)
                
                self.viewModel?.parameters = temp
                self.viewModel?.inputArtists()
            }
        }
        
        bindCollectionView()
        bindViewModel()
        
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 34, paddingBottom: 0, paddingRight: 34, width: 0, height: 50)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        searchTextField.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 14, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 50)
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
                    DispatchQueue.main.async {
                        self.artists = response
                        self.filterArtists = self.artists
                        self.collectionView.reloadData()
                }
            }
        }
        
        viewModel?.inputHandler = { [weak self] change in
            
            guard let _ = self else {
                return
            }
            
            switch change {
            case .didEncounterError(let error):
                print("error \(error?.statusMessage ?? "")")
            case .didPushNavigation:
                print("success follow artists")
                self?.clearNotifsNav()
                let mainTabControlelr = MainTabController()
                mainTabControlelr.modalPresentationStyle = .fullScreen
                self?.present(mainTabControlelr, animated: true, completion: nil)
            }
        }
    }
    
    public func clearNotifsNav(){
        if let tab = self.view.window?.rootViewController, tab is MainTabController {
             let mainTab = tab as? MainTabController
             mainTab?.notifsNavigate?.cleanNotif()
             mainTab?.notifsNavigate = nil
         }
     }
    
    func bindCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.anchor(top: searchTextField.bottomAnchor, left: view.leftAnchor, bottom: navigationBottom.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 34, paddingBottom: 0, paddingRight: 34, width: 0, height: 0)
    }
    
    @objc func handleTappedSearchTextField() {
        self.navigationController?.pushViewController(SearchAccountController(viewModel: SearchAccountViewModel(networkModel: AuthNetworkModel())), animated: true)
    }
}

// MARK:- UICollectionViewDelegateFlowLayout & UICollectionViewDataSource

extension FollowArtistController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
