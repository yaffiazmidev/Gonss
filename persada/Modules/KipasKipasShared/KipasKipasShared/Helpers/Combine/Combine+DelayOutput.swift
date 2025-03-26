import Combine

public extension Publisher where Failure == AnyError {
    func delayOutput(for interval: TimeInterval, scheduler: DispatchQueue = .main) -> AnyPublisher<Output, Failure> {
        self.flatMap { value in
            Future<Output, Failure> { promise in
                scheduler.asyncAfter(deadline: .now() + interval) {
                    promise(.success(value))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension Swift.Result where Failure == AnyError {
    func delayOutput(for interval: TimeInterval, scheduler: DispatchQueue = .main) -> AnyPublisher<Success, Failure> {
        Future<Success, Failure> { promise in
            scheduler.asyncAfter(deadline: .now() + interval) {
                switch self {
                case let .success(value):
                    promise(.success(value))
                case let .failure(error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
