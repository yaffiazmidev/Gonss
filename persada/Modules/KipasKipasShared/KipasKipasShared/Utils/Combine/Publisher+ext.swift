import Combine

public extension Publisher {
    func sinkIgnoreCompletion() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
   }
    
    func sinkReceiveValue(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }
}
