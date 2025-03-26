//
//  SearchAccountViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 22/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class SearchAccountViewModel {
    
    // MARK:- Public Property
    
    let networkModel: AuthNetworkModel?
    var changeHandler: ((ChangeSearchAccountViewModel) -> Void)?
    var inputHandler: ((InputAccountViewModel) -> Void)?
    var contentArtists = [ContentArtist]()
    var parameters: String?
    var searchText: String?
    
    // MARK:- Public Mehtod
    
    init(networkModel: AuthNetworkModel ) {
        self.networkModel = networkModel
    }
    
    func inputArtists() {
        networkModel?.followArtists(self.parameters ?? "", .followArtist, { [weak self] (result) in
            
            guard let self = self else {
                return
            }
            
            switch result {
                case .failure(let error):
                    print("error \(error?.statusMessage ?? "")")
                case .success(let response):
                    
                    if response.code == "1000" {
                        self.emitArtist(.didPushNavigation)
                }
            }
            
        })
    }
    
    func searchArtist() {
        networkModel?.showArtists(.searchArtists(name: searchText ?? ""), completieon: { [weak self] (result) in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                print("error \(error?.statusMessage ?? "")")
            case .success(let response):
                self.contentArtists = response.data?.content ?? []
                self.emit(.didUpdateFollowArtistUser(contents: self.contentArtists))
            }
        })
    }
    
    func getCellViewModel(at index: Int) -> ContentArtist? {
        
        guard index < contentArtists.count else {
            return nil
        }
        
        return contentArtists[index]
    }
    
    func emit(_ change: ChangeSearchAccountViewModel) {
        self.changeHandler?(change)
    }
    
    func emitArtist(_ param: InputAccountViewModel) {
        self.inputHandler?(param)
    }
}

enum ChangeSearchAccountViewModel {
    case didUpdateFollowArtistUser(contents: [ContentArtist])
    case didEncounterError(ErrorMessage?)
}

enum InputAccountViewModel {
    case didPushNavigation
    case didEncounterError(ErrorMessage?)
}
