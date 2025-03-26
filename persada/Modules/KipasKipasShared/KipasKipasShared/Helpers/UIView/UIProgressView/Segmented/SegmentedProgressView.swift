import UIKit

public final class SegmentedProgressView: UIView {
    
    public weak var delegate: SegmentedProgressViewDelegate?
    public weak var dataSource: SegmentedProgressViewDataSource? {
        didSet {
            if segments.isEmpty {
                drawSegments()
            }
        }
    }
    
    private var numberOfSegments: Int {
        return dataSource?.numberOfSegments ?? 0
    }
    
    private var lastSegmentIndex: Int {
        return numberOfSegments - 1
    }
    
    private var segmentDuration: TimeInterval {
        return dataSource?.segmentDuration ?? 1
    }
    
    private var paddingBetweenSegments: CGFloat {
        return dataSource?.paddingBetweenSegments ?? 3
    }
    
    private var trackColor: UIColor {
        return dataSource?.trackColor ?? .clear
    }
    
    private var progressColor: UIColor {
        return dataSource?.progressColor ?? .clear
    }
    
    private var segments = [LineProgress]()
    private var timer: Timer?
    
    private var isPlaying: Bool = false
    
    private var SEGMENT_MAX_WIDTH: CGFloat = 0
    
    private let PROGRESS_SPEED: Double = 100
    
    private var PROGRESS_INTERVAL: CGFloat {
        let tolerance: TimeInterval = 0.5
        let duration = segmentDuration - tolerance
        let value = duration * PROGRESS_SPEED
        let result = SEGMENT_MAX_WIDTH / CGFloat(value)
        return result
    }
    
    private var TIMER_TIMEINTERVAL: Double {
        return 1 / PROGRESS_SPEED
    }
    
    // MARK: Properties
    public private(set) var isPaused: Bool = false
    public private(set) var currentIndex: Int = 0
    
    private var isAutoPlayToNextIndex = true
    
    // MARK: Initializer
    public override init(frame: CGRect) {
        super.init(frame : frame)
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public func removeObserver() {
        reset()
        delegate = nil
        dataSource = nil
    }
    
    // MARK:- Private
    private func drawSegments() {
        segments.removeAll()
        
        let remainingWidth = frame.size.width - (paddingBetweenSegments * CGFloat(lastSegmentIndex))
        let widthOfSegment = remainingWidth / CGFloat(numberOfSegments)
        let heightOfSegment = frame.size.height
        
        SEGMENT_MAX_WIDTH = widthOfSegment
        
        var originX: CGFloat = 0
        let originY: CGFloat = 0
        
        for index in 0..<numberOfSegments {
            originX = (CGFloat(index) * widthOfSegment) + (CGFloat(index) * paddingBetweenSegments)
            
            let frameOfTrackView = CGRect(x: originX, y: originY, width: widthOfSegment, height: heightOfSegment)
            
            let trackView = crateTrackView(backgroundColor: trackColor)
            trackView.frame = frameOfTrackView
            addSubview(trackView)
            
            if let cornerType = dataSource?.roundCornerType {
                switch cornerType {
                case .roundCornerSegments(let cornerRadius):
                    trackView.borderAndCorner(cornerRadius: cornerRadius, borderWidth: 0, borderColor: nil)
                case .roundCornerBar(let cornerRadius):
                    if index == 0 {
                        trackView.roundCorners(corners: [.topLeft, .bottomLeft], radius: cornerRadius)
                    } else if index == lastSegmentIndex {
                        trackView.roundCorners(corners: [.topRight, .bottomRight], radius: cornerRadius)
                    }
                case .none:
                    break
                }
            }
            
            let deafultFrameOfProgressView = CGRect(x: 0, y: 0, width: 0, height: heightOfSegment)
            let progressView = createProgressView(backgroundColor: progressColor)
            progressView.frame = deafultFrameOfProgressView
            trackView.addSubview(progressView)
            
            segments.append(progressView)
        }
    }
    
    private func crateTrackView(backgroundColor: UIColor) -> UIView {
        let trackView = UIView()
        trackView.clipsToBounds = true
        trackView.isUserInteractionEnabled = false
        trackView.backgroundColor = backgroundColor
        return trackView
    }
    
    private func createProgressView(backgroundColor: UIColor) -> LineProgress {
        let progressView = LineProgress()
        progressView.clipsToBounds = true
        progressView.isUserInteractionEnabled = false
        progressView.backgroundColor = backgroundColor
        progressView.progressBarColor = progressColor
        return progressView
    }
    
    // MARK:- Timer
    private func setUpTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: TIMER_TIMEINTERVAL, target: self, selector: #selector(animationTimerMethod), userInfo: nil, repeats: true)
        } else {
            resume()
        }
    }
    
    @objc private func animationTimerMethod() {
        if isPaused { return }
        animateSegment()
    }
    
    // MARK:- Animation
    private func animateSegment() {
        guard currentIndex < segments.count else { return }
        
        let progressView = segments[currentIndex]
        progressView.isHidden = false
        
        let lastProgress = progressView.frame.size.width
        let newProgress = lastProgress + PROGRESS_INTERVAL
        
        progressView.updateWidth(newWidth: newProgress)
        
        if newProgress >= SEGMENT_MAX_WIDTH {
            if currentIndex == lastSegmentIndex {
                timer?.invalidate()
                timer = nil
                delegate?.segmentedProgressView(completedAt: currentIndex, isLastIndex: true)
            } else {
                delegate?.segmentedProgressView(completedAt: currentIndex, isLastIndex: false)
            }
            
            isPlaying = isAutoPlayToNextIndex == false
        }
    }
    
    // MARK:- Actions
    public func start() {
        setUpTimer()
    }
    
    public func pause() {
        isPaused = true
    }
    
    public func resume() {
        isPaused = false
    }
    
    public func nextSegment() {
        if currentIndex < lastSegmentIndex {
            isPaused = true
            
            let progressView = segments[currentIndex]
            progressView.updateWidth(newWidth: SEGMENT_MAX_WIDTH)
            
            currentIndex += 1
            isPaused = false
            
            if timer == nil {
                start()
            } else {
                animateSegment()
            }
        }
    }
    
    public func play(at index: Int) {
        guard isPlaying == false else { return }
        
        reset()
        
        if index <= lastSegmentIndex {
            for (i, segment) in segments.enumerated() {
                segment.backgroundColor = progressColor
                segment.stopAnimating()
                
                if i < index {
                    segment.updateWidth(newWidth: SEGMENT_MAX_WIDTH)
                } else if i == index {
                    segment.updateWidth(newWidth: 0)
                }
            }
            
            isAutoPlayToNextIndex = false
            currentIndex = index
            isPaused = false
            isPlaying = true
            
            start()
        }
    }
    
    public func reset(at index: Int) {
        reset()
        
        if index <= lastSegmentIndex {
            for (i, segment) in segments.enumerated() {
                segment.backgroundColor = progressColor
                
                if i < index {
                    segment.updateWidth(newWidth: SEGMENT_MAX_WIDTH)
                } else if i == index {
                    segment.updateWidth(newWidth: 0)
                }
            }
            
            isAutoPlayToNextIndex = false
            currentIndex = index
            isPaused = false
        }
    }
    
    public func loading(at index: Int) {
        isPaused = true
        currentIndex = index
        reset(at: index)
        
        if index <= lastSegmentIndex {
            let progress = segments[index]
            progress.backgroundColor = trackColor
            progress.isHidden = false
            progress.progressBarColor = progressColor
            progress.updateWidth(newWidth: SEGMENT_MAX_WIDTH)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                progress.startAnimating()
            }
        }
    }
    
    public func previousSegment() {
        if currentIndex > 0 {
            isPaused = true
            
            let currentProgressView = segments[currentIndex]
            currentProgressView.updateWidth(newWidth: 0)
            
            currentIndex -= 1
            
            let progressView = segments[currentIndex]
            progressView.updateWidth(newWidth: 0)
            
            isPaused = false
            
            if timer == nil {
                start()
            } else {
                animateSegment()
            }
        }
    }
    
    public func restart() {
        reset()
        start()
    }
    
    public func reset() {
        isPlaying = false
        isPaused = true
        
        timer?.invalidate()
        timer = nil
        
        for index in 0..<numberOfSegments {
            let progressView = segments[index]
            progressView.updateWidth(newWidth: 0)
        }
        
        currentIndex = 0
        isPaused = false
    }
    
    public func restartCurrentSegment() {
        isPaused = true
        
        let currentProgressView = segments[currentIndex]
        currentProgressView.updateWidth(newWidth: 0)
        
        isPaused = false
        
        if timer == nil {
            start()
        } else {
            animateSegment()
        }
    }
    
    // MARK:- Set Progress Manually
    public func setProgressManually(index: Int, progressPercentage: CGFloat) {
        
        if index < segments.count && index >= 0 {
            timer?.invalidate()
            timer = nil
            
            currentIndex = index
            var percentage = progressPercentage
            
            if progressPercentage > 100 {
                percentage = 100
            }
            
            let currentProgressView: UIView = segments[currentIndex]
            let width: CGFloat = (SEGMENT_MAX_WIDTH * percentage) / 100
            currentProgressView.updateWidth(newWidth: width)
        }
    }
}

private extension UIView {
    func updateWidth(newWidth: CGFloat) {
        let rect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newWidth, height: self.frame.size.height)
        self.frame = rect
    }
    
    func borderAndCorner(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor?) {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

