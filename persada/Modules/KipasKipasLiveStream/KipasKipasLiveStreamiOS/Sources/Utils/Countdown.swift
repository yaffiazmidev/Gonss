import Foundation

class Countdown {
    
    private let step: Double = 1
    private var timer: Timer?
    
    private let startValue: Double
    private let countdownElapsed: (Double) -> Void
    private let isFinished: (Bool) -> Void
    
    private var currentValue: Double = 0
    
    init(
        startValue: Double,
        countdownElapsed: @escaping (Double) -> Void,
        isFinished: @escaping (Bool) -> Void
    ) {
        self.startValue = startValue
        self.countdownElapsed = countdownElapsed
        self.isFinished = isFinished
    }
    
    deinit {
        stopTimer()
    }
    
    private func startTimer() {
        currentValue = startValue
        
        let action: (Timer) -> Void = { [weak self] timer in
            guard let self = self else { return }
            
            if self.currentValue <= 0 {
                self.stopTimer()
            } else {
                self.isFinished(false)
                self.countdownElapsed(self.currentValue)
                self.currentValue -= 1
            }
        }
        countdownElapsed(currentValue)
        timer = Timer.scheduledTimer(withTimeInterval: step, repeats: true, block: action)
    }
    
    func toggle() {
        guard timer != nil else {
            startTimer()
            return
        }
        stopTimer()
    }
    
    private func stopTimer() {
        isFinished(true)
        timer?.invalidate()
        timer = nil
    }
}
