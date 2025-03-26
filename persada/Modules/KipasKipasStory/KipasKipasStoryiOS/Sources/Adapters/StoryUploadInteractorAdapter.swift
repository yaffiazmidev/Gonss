//
//  StoryUploadInteractorAdapter.swift
//  KipasKipasStoryiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/06/24.
//

import Foundation
import KipasKipasStory
import Combine

public final class StoryUploadInteractorAdapter {
    public typealias StoryUploadResult = Swift.Result<EmptyData, Error>
    
    private var cancellable: AnyCancellable?
    
    private let uploader: (StoryUploadRequest) -> StoryUploader
    
    public init(uploader: @escaping (StoryUploadRequest) -> StoryUploader) {
        self.uploader = uploader
    }
    
    public func upload(_ param: StoryUploadRequest, completion: @escaping (StoryUploadResult) -> Void) {
        cancellable = uploader(param)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }, receiveValue: { response in
                completion(.success(response))
            })
    }
}
