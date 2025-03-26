//
//  ProfilePostViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 17/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class ProfilePostViewModel {
    
    // MARK: - Public  Property
    
    let networkModel: ProfileNetworkModel?
    var postHandler: ((PostProfileViewModelChange) -> Void)?
    var id: String = ""
    var type: String = ""
    var currentPage: Int = 0
    var userId: String = ""
    var postId: String = ""
    var statusLike: String = ""
    
    var totalCount: Int {
        return total
    }
    
    var currentCount: Int {
        return cellViewModels.count - 1
    }
    
    // MARK: - Private Property
    
    private var cellViewModels = [ProfilePostCellViewModel]()
    private var total = 0
    private var isFetchInProgress = false
    
    // MARK: - Public Method
    
    init(id: String, type: String, networkModel: ProfileNetworkModel) {
        self.networkModel = networkModel
        self.id = id
        self.type = type
    }
    
    func posts(at index: Int) -> ProfilePostCellViewModel {
        return cellViewModels[index]
    }
    
    func fetchPosts() {
        
        guard !self.isFetchInProgress else {
            return
        }
        
        self.isFetchInProgress = true
        
        networkModel?.fetchPostAccount(.postAccount(id: self.id, type: self.type, page: currentPage), { [weak self] (result) in
            
            guard let self = self else {
                return
            }
            
            switch result {
                
            case .failure(let error):
                DispatchQueue.main.async { [unowned self] in
                    self.emit(.didEncounterError(error))
                }

            case .success(let response):
                    
                DispatchQueue.main.async { [weak self] in
                    
                    guard let self = self else { return }
                    
                    self.currentPage += 1
                    self.isFetchInProgress = false

                    if let reponse = response.data?.content {
                        self.total = response.data?.totalElements ?? 0
                        
                        let resultSeleb = reponse.map{ (seleb) -> ProfilePostCellViewModel in
                            return ProfilePostCellViewModel(value: seleb)!
                        }
											DispatchQueue.global(qos: .background).async {
												self.cellViewModels.append(contentsOf: resultSeleb)
											}
                        
                        if response.data?.number ?? 0 > 0 {
                            let indexPathsToReload = self.calculateIndexPathsToReload(from: self.cellViewModels)
                            self.emit(.didUpdatePostProfile(newIndexPathsToReload: indexPathsToReload))
                        } else {
                            self.emit(.didUpdatePostProfile(newIndexPathsToReload: .none))
                        }
                    }
                }
            }
        })
    }
    
    func emit(_ change: PostProfileViewModelChange) {
        postHandler?(change)
    }
    
    private func calculateIndexPathsToReload(from newModerators: [ProfilePostCellViewModel]) -> [IndexPath] {
        let startIndex = cellViewModels.count - newModerators.count
        let endIndex = startIndex + newModerators.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}

enum PostProfileViewModelChange {
    case didUpdatePostProfile(newIndexPathsToReload: [IndexPath]?)
    case didEncounterError(ErrorMessage?)
}
