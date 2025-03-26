import UIKit
import KipasKipasShared

final class CountDownViewController: UIViewController {
    
    private let circleView = UIView()
    private let counterLabel = UILabel()
    
    var onCountdownFinished: (() -> Void)?
    
    private lazy var countdown = Countdown(
        startValue: 3,
        countdownElapsed: { [weak self] value in
            self?.counterLabel.text = String(format: "%0.0f", value)
        },
        isFinished: { [weak self] isFinished in
            self?.counterLabel.isHidden = isFinished
            self?.circleView.isHidden = isFinished
            
            if isFinished {
                self?.onCountdownFinished?()
            }
        })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        countdown.toggle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleView.layer.cornerRadius = circleView.bounds.height / 2
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        configureCircleView()
        configureCounterLabel()
    }
    
    private func configureCircleView() {
        circleView.isHidden = true
        circleView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.addSubview(circleView)
        circleView.anchors.width.equal(100)
        circleView.anchors.height.equal(100)
        circleView.anchors.center.align()
    }
    
    private func configureCounterLabel() {
        counterLabel.isHidden = true
        counterLabel.textColor = .white
        counterLabel.font = .roboto(.medium, size: 60)
        counterLabel.textAlignment = .center
        
        circleView.addSubview(counterLabel)
        counterLabel.anchors.edges.pin()
        counterLabel.anchors.center.align()
    }
}
