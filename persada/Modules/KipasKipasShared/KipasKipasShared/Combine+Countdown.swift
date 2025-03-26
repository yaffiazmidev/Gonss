import Foundation
import Combine

public struct CountDownTimer: Publisher {
    public struct TimeRemaining {
        public let hours, minutes, seconds, totalSeconds: Int
        public let outputText: String
    }
    
    public typealias Output = TimeRemaining
    public typealias Failure = Never
    
    public let duration: TimeInterval
    public let repeats: Bool
    public let outputUnits: NSCalendar.Unit
    
    public init(
        duration: TimeInterval,
        repeats: Bool = false,
        outputUnits: NSCalendar.Unit = [.hour, .minute, .second]
    ) {
        self.duration = duration
        self.repeats = repeats
        self.outputUnits = outputUnits
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        let subscription = CountDownSubscription(
            duration: duration,
            repeats: repeats,
            outputUnits: outputUnits,
            subscriber: subscriber
        )
        subscriber.receive(subscription: subscription)
    }
}

private extension CountDownTimer {
    class CountDownSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        
        private let repeats: Bool
        private let duration: TimeInterval
        private let outputUnits: NSCalendar.Unit
        
        private var subscriber: S?
        private var timerCancellable: AnyCancellable?
        
        init(
            duration: TimeInterval,
            repeats: Bool,
            outputUnits: NSCalendar.Unit,
            subscriber: S
        ) {
            self.repeats = repeats
            self.duration = duration
            self.outputUnits = outputUnits
            self.subscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            startTimer()
        }
        
        func cancel() {
            stopTimer()
        }
        
        func startTimer() {
            timerCancellable = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .dispatchOnMainQueue()
                .map { _ in self.duration }
                .scan(self.duration, { current, _ in
                    return Swift.max(-1, current - 1)
                })
                .handleEvents(receiveOutput: { [weak self] timeRemaining in
                    guard let self = self else { return }
                    
                    if timeRemaining < 0 {
                        stopTimer()
                        
                        if repeats {
                            startTimer()
                        } else {
                            subscriber?.receive(completion: .finished)
                        }
                    }
                })
                .sink(receiveValue: { [weak self] timeRemaining in
                    guard let self = self else { return }
                    _ = subscriber?.receive(remaining(from: timeRemaining))
                })
        }
        
        func stopTimer() {
            timerCancellable?.cancel()
            timerCancellable = nil
        }
        
        func remaining(from interval: TimeInterval) -> TimeRemaining {
            let hours = Int(interval / 3600)
            let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
            
            return .init(
                hours: hours,
                minutes: minutes,
                seconds: seconds,
                totalSeconds: Int(interval), 
                outputText: output(from: interval)
            )
        }
        
        func output(from interval: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = outputUnits
            
            return formatter.string(from: interval) ?? "0s"
        }
    }
}

public extension TimeInterval {
    static var secondsUntilMidnight: TimeInterval {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 25200)!
        
        let currentDate = Date()
        
        let midnight = calendar.startOfDay(for: currentDate).addingTimeInterval(24 * 60 * 60)
        let timeInterval = midnight.timeIntervalSince(currentDate)
        return timeInterval
    }
}
