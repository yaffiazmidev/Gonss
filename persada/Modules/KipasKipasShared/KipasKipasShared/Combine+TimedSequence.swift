import Combine

public final class TimedSequence<T>  {
    
    typealias DelayPublisher = Publishers.Autoconnect<Timer.TimerPublisher>
    
    private var array: [T] = [] {
        didSet {
            if !array.isEmpty {
                publish()
            }
        }
    }
    
    private let delayPublisher: DelayPublisher
    private let closure: (T) -> Void
    
    private var cancellable: AnyCancellable?
    
    public init(interval: TimeInterval, closure: @escaping (T) -> Void) {
        self.delayPublisher = Timer.publish(
            every: interval,
            on: .main,
            in: .default
        ).autoconnect()
        self.closure = closure
    }
    
    public func append(_ newValue: T) {
        array.append(newValue)
    }
    
    private func publish() {
        let timedJointPublisher = Publishers.Zip(array.publisher, delayPublisher)
        cancellable = timedJointPublisher
            .sink(receiveValue: { [weak self] val in
                guard let self = self else { return }
                closure(val.0)
                array.removeAll()
            })
    }
}
