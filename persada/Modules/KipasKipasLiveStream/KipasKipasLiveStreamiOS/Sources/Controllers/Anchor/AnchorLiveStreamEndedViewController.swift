import UIKit
import Combine
import KipasKipasShared
import KipasKipasLiveStream

public final class AnchorLiveStreamEndedViewController: UIViewController {
    
    private let liveEndedView = AnchorLiveEndedView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    var onTapBackButton: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        view.addSubview(liveEndedView)
        liveEndedView.anchors.width.equal(250)
        liveEndedView.anchors.height.equal(280)
        liveEndedView.anchors.center.align()
        
        liveEndedView.backButton.tapPublisher
            .sink { [weak self] in
                self?.onTapBackButton?()
            }
            .store(in: &cancellables)
    }
    
    func setSummary(_ summary: LiveStreamSummary) {
        liveEndedView.totalDurationLabel.text = String.duration(from: TimeInterval(summary.totalDuration ?? 0))
        liveEndedView.totalLikesLabel.text = String(summary.totalLike ?? 0)
        liveEndedView.totalViewersLabel.text = String(summary.totalAudience ?? 0)
        liveEndedView.totalDiamondLabel.text = String(summary.totalDiamond ?? 0)
    }
}
