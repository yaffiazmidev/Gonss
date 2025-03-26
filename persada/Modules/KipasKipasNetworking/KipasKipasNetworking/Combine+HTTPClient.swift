import Foundation
import Combine

public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(request: URLRequest) -> Publisher {
        var task:  Task<Void, Never>?
         
        return Deferred {
            Future { promise in
               task = Task {
                    do {
                        let (data, response) = try await self.request(from: request)
                        promise(.success((data, response)))
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
