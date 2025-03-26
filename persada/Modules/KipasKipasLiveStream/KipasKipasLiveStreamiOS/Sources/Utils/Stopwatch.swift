import Foundation

class Stopwatch {
    
    private let step: Double = 1
    private var timer: Timer?
    
    //The time when counting was started
    private var from: Date?
    
    //The time when counting was stopped
    private var to: Date?

    // The time when user pause timer last one
    private var timeIntervalTimelapsFrom: TimeInterval?
    // The total time before user paused timer
    private var timerSavedTime: TimeInterval = 0

    typealias TimeUpdated = (_ time: Double) -> Void
    
    private let timeUpdated: TimeUpdated

    var isPaused: Bool {
        return timer == nil
    }
 
    init(timeUpdated: @escaping TimeUpdated) {
        self.timeUpdated = timeUpdated
    }
    
    deinit {
        deinitTimer()
    }
  
    func toggle() {
        guard timer != nil else {
            initTimer()
            return
        }
        deinitTimer()
    }
    
    func stop() {
        deinitTimer()
        from = nil
        to = nil
        timeUpdated(timerSavedTime)
    }
    
    private func initTimer() {
        let action: (Timer)->Void = { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            let to = Date().timeIntervalSince1970
            let timeIntervalFrom = strongSelf.timeIntervalTimelapsFrom ?? to
            let time = strongSelf.timerSavedTime + (to - timeIntervalFrom)
            strongSelf.timeUpdated(round(time))
        }
        if from == nil {
            from = Date()
        }
        if timeIntervalTimelapsFrom == nil {
            timeIntervalTimelapsFrom = Date().timeIntervalSince1970
        }
        timer = Timer.scheduledTimer(
            withTimeInterval: step,
            repeats: true,
            block: action
        )
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func deinitTimer() {
        if let timeIntervalTimelapsFrom = timeIntervalTimelapsFrom {
            let to = Date().timeIntervalSince1970
            timerSavedTime += to - timeIntervalTimelapsFrom
        }
        
        timer?.invalidate()
        timer = nil
        timeIntervalTimelapsFrom = nil
    }
}
