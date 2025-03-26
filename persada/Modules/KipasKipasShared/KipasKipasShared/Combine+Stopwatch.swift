import Foundation
import Combine

public typealias AnyStopwatch = AnyCancellable

public struct StopwatchPublisher: Publisher {
    
    public struct ElapsedTime {
        public let seconds: Int
        public let formattedOutput: String
    }
    
    public typealias Output = ElapsedTime
    public typealias Failure = Never
    
    private let interval: TimeInterval
    
    public init(interval: TimeInterval = 1.0) {
        self.interval = interval
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = StopwatchSubscription(subscriber: subscriber, interval: interval)
        subscriber.receive(subscription: subscription)
    }
}

private extension StopwatchPublisher {
    class StopwatchSubscription<S: Subscriber>: Subscription where S.Input == Output {
        
        private var cancellable: AnyCancellable?
        private var startTime: Date?
        
        var isRunning: Bool {
            return cancellable != nil
        }
        
        private let interval: TimeInterval
        private var subscriber: S?
        
        init(
            subscriber: S,
            interval: TimeInterval
        ) {
            self.subscriber = subscriber
            self.interval = interval
        }
        
        func request(_ demand: Subscribers.Demand) {
            start()
        }
        
        func cancel() {
            stop()
        }
        
        func start() {
            guard !isRunning else { return }
            
            startTime = Date()
            cancellable = Timer.publish(every: interval, on: .main, in: .common)
                .autoconnect()
                .dispatchOnMainQueue()
                .sink { [weak self] _ in
                    guard let self = self, let startTime = self.startTime else { return }
                    let interval = Date().timeIntervalSince(startTime)
                    _ = subscriber?.receive(remaining(from: interval))
                }
        }
        
        func stop() {
            cancellable?.cancel()
            cancellable = nil
        }
        
        func remaining(from interval: TimeInterval) -> ElapsedTime {
            let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
            return .init(
                seconds: seconds,
                formattedOutput: output(from: interval)
            )
        }
        
        func output(from interval: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
            
            return formatter.string(from: interval) ?? "00:00:00"
        }
        
        deinit {
            cancellable?.cancel()
        }
    }
}
