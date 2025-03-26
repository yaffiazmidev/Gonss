import Combine

public extension ImageLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func getPublisher(url: URL) -> Publisher {
        var task: Task<Void, Never>?
        
        return Deferred {
            Future { promise in
                task = Task {
                     do {
                         let data = try await self.loadImage(from: url)
                         promise(.success(data))
                     } catch {
                         promise(.failure(error))
                     }
                 }
            }
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
            task = nil
        })
        .eraseToAnyPublisher()
    }
}

