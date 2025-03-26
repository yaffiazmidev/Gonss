//
//  StoryViewersInteractorAdapter.swift
//  KipasKipasStoryiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/06/24.
//

import Foundation
import KipasKipasStory
import Combine

public final class StoryViewersInteractorAdapter: StoryViewersInteractor {
    private var cancellable: AnyCancellable?
    
    private let loader: (StoryViewerRequest) -> StoryViewersLoader
    
    public init(loader: @escaping (StoryViewerRequest) -> StoryViewersLoader) {
        self.loader = loader
    }
    
    public func load(_ param: StoryViewerRequest, completion: @escaping (StoryViewersResult) -> Void) {
//        cancellable = loader(param)
//            .dispatchOnMainQueue()
//            .sink(receiveCompletion: { result in
//                switch result {
//                case .finished:
//                    break
//                case .failure(let failure):
//                    completion(.failure(failure))
//                }
//            }, receiveValue: { response in
//                completion(.success(response.data.content))
//            })
    }
}
