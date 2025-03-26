//
//  ImageDataStoreSpy.swift
//  KipasKipasNetworkingTests
//
//  Created by PT.Koanba on 04/04/22.
//

import Foundation
import KipasKipasNetworking

class ImageDataStoreSpy: ImageDataStore {

    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalCompletions = [(ImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(ImageDataStore.InsertionResult) -> Void]()

    func insert(_ data: LocalImageData, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data.data!, for: data.url))
        insertionCompletions.append(completion)
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (ImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
