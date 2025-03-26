//
//  FeedbarController.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/07/22.
//

import UIKit

protocol FeedbarDelegate{
    func hasReachStart()
    func hasChanged(to index:Int)
    func hasReachEnd()
}

enum FeedbarState{
    case stoped, paused, played
}

class FeedbarController: UIViewController {
    private var currentIndex: Int!
    private var barViews: [FeedbarModel]!
    private var animator: UIViewPropertyAnimator?
    private var delegate: FeedbarDelegate!
    
    private var containerView: UIView!
    private var spacing: Double!
    private var horizontalPadding: Double!
    var barCount: Int!
    private var completionInited: Bool!
    var dataHasBeenLoad:[Int] = []
    
    
    var state: FeedbarState!
    
    var isInBackground = false
    
    init(delegate: FeedbarDelegate, container: UIView, durations: [TimeInterval], spacing: Double = 2.0, horizontalPadding: Double = 32.0) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        containerView = container
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        barCount = durations.count
        currentIndex = 0
        barViews = []
        removeFromContainer() //untuk clean containerView (ada kasus feedbar menumpuk)
        generateFeedbar(for: barCount, durations: durations)
        state = .stoped
        completionInited = false
        view.layoutSubviews()
        createBackgroundObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("*** feedbar deinit")
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        self.isInBackground = true
        //self.setKeyLastOpen()
        //stop()
        pause()
        NotificationCenter.default.removeObserver(self)
        createForegroundObserver()
        print("*** feedbar enter background ", state)
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        self.isInBackground = false
        play()
        NotificationCenter.default.removeObserver(self)
        createBackgroundObserver()
        print("*** feedbar enter foreground ", state)
    }
}

// MARK: - Observer
extension FeedbarController{
    func createForegroundObserver(){
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    func createBackgroundObserver(){
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }
}

// MARK: Private Zone
private extension FeedbarController{
    
    private func widthPerBar() -> CGFloat{
        let widthContainer = UIScreen.main.bounds.width - horizontalPadding
        let widthSpacing = spacing * Double(barCount - 1)
        return (widthContainer - widthSpacing) / CGFloat(barCount)
    }
    
    private func originX(for index: Int) -> CGFloat {
        let position = widthPerBar() + CGFloat(spacing)
        return CGFloat(index) * position
    }
    
    private func generateFeedbar(for count: Int, durations: [TimeInterval]){
        for i in 0..<count {
            let view = FeedbarView()
            view.frame.size.width = widthPerBar()
            view.frame.size.height = 2
            view.frame.origin.x = originX(for: i)
            let bar = FeedbarModel(view: view, duration: durations[i])
            barViews.append(bar)
            containerView.addSubview(barViews[i].view)
        }
    }
    
    private func configureProgressBar(for index: Int){
        stop()
        print("*** feedbar - configureProgressBar index : \(index) ; current index : \(currentIndex)")
        if currentIndex < index {
            for i in 0..<index {
                print("*** feedbar - configureProgressBar inside if \(i) of \(0..<index)")
                barViews[i].view.progressView.frame.size.width = barViews[i].view.frame.size.width
            }
        }else{
            for i in index...currentIndex {
                print("*** feedbar - configureProgressBar inside else \(i) of \(index...currentIndex)")
                barViews[i].view.progressView.frame.size.width = 0
            }
        }
    }
    
    private func currentBar() -> FeedbarModel {
        print("*** feedbar \(currentIndex + 1) of \(barViews.count) # barCount : \(barCount)")
        if currentIndex < barCount{
            return barViews[currentIndex]
        }
        return barViews.first!
    }
}

extension FeedbarController {
    
    func setProgressCurrentBar(progress: Float){
        guard !(progress.isNaN || progress.isInfinite) else {
            print("***- progress value not valid")
            return
        }
        
        let progressView = currentBar().view.frame.size.width * CGFloat(progress)
        print("***- progress = \(progress) for index \(currentIndex)")
        
        if progress == 0.0 {
            currentBar().view.progressView.frame.size.width = progressView
            configureProgressBar(for: currentIndex)
        } else {
            state = .played
            UIView.animate(
                withDuration: 1.0,
                delay: 0.0,
                options: [.curveLinear, .beginFromCurrentState, .preferredFramesPerSecond60],
                animations: {
                    if progress != 0.0 {
                        self.currentBar().view.progressView.frame.size.width = progressView
                        self.currentBar().view.progressView.layoutIfNeeded()
                    }
                }, completion: nil)
        }
    }
    
    func removeFromContainer(){
        if containerView.subviews.count > 0{
            containerView.subviews.forEach({ $0.removeFromSuperview()})
        }
    }
    
    func next(animated: Bool){
        let newIndex = currentIndex + 1
        if newIndex < barCount {
            if animated {
                animate(to: newIndex)
            }
        }else{
            //            print("***- hasReachEnd with current : \(currentIndex) # \(newIndex) of \(barCount)")
            delegate.hasReachEnd()
        }
    }
    
    func previous(){
        let newIndex = currentIndex - 1
        if newIndex < 0 {
            delegate.hasReachStart()
        }else{
            animate(to: newIndex)
        }
    }
    
    func pause(){
        if let animator = animator {
            if animator.isRunning {
                animator.pauseAnimation()
                state = .paused
            }
        }
    }
    
    func play(){
        if let animator = animator {
            if !animator.isRunning {
                animator.startAnimation()
                state = .played
            }
        }
    }
    
    
    func stop() {
        currentBar().view.progressView.layer.removeAllAnimations()
        if let animator = animator {
            animator.stopAnimation(true)
            if animator.state == .stopped {
                animator.finishAnimation(at: .current)
                state = .stoped
            }
        }
    }
    
    func resetFeedbar(){
        currentIndex = 0
        for i in 0..<barViews.count{
            barViews[i].view.progressView.frame.size.width = 0
        }
    }
    
    func jump(to index: Int = 0, whenOutOfRange: (() -> Void)? = nil){
        let inRange = index < barCount
        if !inRange {
            whenOutOfRange?()
            return
        }
        //        print("***- animate to index \(index) of \(barCount)")
        currentBar().view.progressView.layer.removeAllAnimations()
        configureProgressBar(for: index)
        currentIndex = index
        delegate.hasChanged(to: index)
    }
    
    
    func animate(to index: Int = 0, enableNext: Bool = true, whenOutOfRange: (() -> Void)? = nil){
        jump(to: index, whenOutOfRange: whenOutOfRange)
        if let _ = animator {
            animator = nil
        }
        
        
        animator = UIViewPropertyAnimator(duration: self.currentBar().duration, curve: .linear) { [weak self] in
            guard let self = self else { return }
            self.currentBar().view.progressView.frame.size.width = self.currentBar().view.frame.size.width
        }
        
        if(!isInBackground){
            if(enableNext) {
                animator?.addCompletion { [weak self] (position) in
                    if position == .end  {
                        print("**** animate next")
                        self?.next(animated: true)
                    }
                }
            }
            animator?.isUserInteractionEnabled = false
            animator?.startAnimation()
            state = .played
        }
    }
    
}
