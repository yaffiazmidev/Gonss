import Combine

public final class DelayedTunnel<T>  {
        
    private let values = PassthroughSubject<T, Never>()
    private var tempStorage: [T] = []
    
    private let interval: TimeInterval
    private let closure: (T) -> Void
    
    private var cancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?
    
    public init(interval: TimeInterval, closure: @escaping (T) -> Void) {
        self.interval = interval
        self.closure = closure
        
        publish()
    }
    
    public func append(_ newValue: T) {
        values.send(newValue)
    }
    
    private func publish() {
        cancellable = values
            .sink { [weak self] value in
            guard let self = self else { return }
            if tempStorage.isEmpty {
                startScheduler()
                closure(value)
            }
            tempStorage.append(value)
        }
    }
    
    private func startScheduler() {
        let timer = Timer.publish(
            every: interval,
            on: RunLoop.main,
            in: .common
        ).autoconnect()
        
        timerCancellable =  timer
            .sink { [weak self] time in
                guard let self = self else { return }
                if !tempStorage.isEmpty {
                    tempStorage.removeAll()
                }
                stopScheduler()
            }
    }
    
    private func stopScheduler() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
