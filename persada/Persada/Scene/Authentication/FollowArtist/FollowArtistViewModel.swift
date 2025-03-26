//
//  FollowArtistViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 22/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class FollowArtistViewModel {
    
    // MARK:- Public Property
    
    let networkModel: AuthNetworkModel?
    var changeHandler: ((ChangeFollowArtistViewModel) -> Void)?
    var inputHandler: ((InputFollowArtistViewModel) -> Void)?
    var contentArtists = [ContentArtist]()
    var parameters: String?
    
    // MARK:- Public Mehtod
    
    init(networkModel: AuthNetworkModel ) {
        self.networkModel = networkModel
        
        fetchArtist()
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
    
    func fetchArtist() {
        networkModel?.showArtists(.showArtists, completieon: { [weak self] (result) in
            
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
    
    func emit(_ change: ChangeFollowArtistViewModel) {
        self.changeHandler?(change)
    }
    
    func emitArtist(_ param: InputFollowArtistViewModel) {
        self.inputHandler?(param)
    }
}

enum ChangeFollowArtistViewModel {
    case didUpdateFollowArtistUser(contents: [ContentArtist])
    case didEncounterError(ErrorMessage?)
}

enum InputFollowArtistViewModel {
    case didPushNavigation
    case didEncounterError(ErrorMessage?)
}
