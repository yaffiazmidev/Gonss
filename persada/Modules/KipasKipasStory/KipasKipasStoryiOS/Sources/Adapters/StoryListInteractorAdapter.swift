//
//  StoryListInteractorAdapter.swift
//  KipasKipasStoryiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/06/24.
//

import Foundation
import KipasKipasStory
import Combine

public final class StoryListInteractorAdapter: StoryListInteractor {
    
    private var cancellable: AnyCancellable?
    
    private let loader: (StoryListRequest) -> StoryListLoader
    
    public init(loader: @escaping (StoryListRequest) -> StoryListLoader) {
        self.loader = loader
    }
    
    public func load(_ param: StoryListRequest, completion: @escaping (StoryDataResult) -> Void) {
        cancellable = loader(param)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }, receiveValue: { response in
                completion(.success(response.data))
            })
    }
}
