import UIKit
import Combine
import KipasKipasShared
import KipasKipasLuckyDraw

public final class GiftBoxDetailViewController: UIViewController, PresentationSizeProtocol {
    
    public var width: Size = .fullscreen
    public var height: Size = .fullscreen
    
    private let mainView = GiftBoxView()
    private let scrollContainer = ScrollContainerView()
    private let backgroundView = UIImageView()
    
    private var toastView: KKToastView!
    private var countdown: AnyCancellable?
    
    private(set) lazy var viewAdapter = ViewAdapter(self)
    
    var onFollow: Closure<Int>?
    var onJoin: Closure<Int>?
    
    private let viewModel: GiftBoxViewModel
    
    public init(viewModel: GiftBoxViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
        updateLayout()
    }
    
    // MARK: API
    func setButtonState(
        _ state: GiftBoxInfoContainerView.ButtonState,
        isLoading: Bool = false
    ) {
        switch viewModel.lotteryCrowdType {
        case .all:
            mainView.setButtonState(state, isLoading: isLoading)
        case .fans:
            mainView.setButtonState(state, isLoading: isLoading)
        default: break
        }
    }
    
    func showToast(_ message: String) {
        toastView = KKToastView()
        toastView.dismissTransition = .fade
        toastView.visiblePosition = .center
        toastView.color = .gravel
        toastView.cornerRadius = 10
        toastView.messageLabel.textColor = .white
        toastView.messageLabel.textAlignment = .center
        toastView.insets = .init(top: view.bounds.height / 4, left: 50, bottom: 0, right: 50)
        toastView.messageLabel.text = message
        toastView.present(duration: 2)
    }
    
    // MARK: Private
    private func configureData() {
        mainView.configure(with: viewModel)
        mainView.setCountdown(schedule: viewModel.schedule, countdownDesc: "00:00:00")
        
        switch viewModel.lotteryCrowdType {
        case .all:
            setButtonState(viewModel.isJoined ? .joined : .join)
        case .fans:
            if viewModel.isJoined {
                setButtonState(.joined)
            } else {
                setButtonState(viewModel.isFans ? .join : .follow)
            }
        default: break
        }
        
        startCountDown()
    }
    
    private func updateLayout() {
        scrollContainer.layoutIfNeeded()
        width = .custom(value: scrollContainer.contentSize.width)
        height = .custom(value: scrollContainer.contentSize.height)
    }
    
    private func startCountDown() {
        let interval24Hours: TimeInterval = 24 * 60 * 60
        let interval = viewModel.schedule.interval
        
        countdown = CountDownTimer(
            duration: interval.truncatingRemainder(dividingBy: interval24Hours),
            outputUnits: [.hour, .minute, .second]
        )
        .handleEvents(receiveOutput: { [weak self] remaining in
            if remaining.totalSeconds < 0 {
                self?.stopCountdown()
            }
        })
        .sink(receiveValue: { [weak self] remaining in
            self?.setCountdown(
                hours: remaining.hours,
                minutes: remaining.minutes,
                seconds: remaining.seconds
            )
        })
    }
    
    private func stopCountdown() {
        countdown?.cancel()
        countdown = nil
    }
    
    private func setCountdown(
        hours: Int,
        minutes: Int,
        seconds: Int
    ) {
        let formattedHours = String(format: "%02d", hours)
        let formattedMinutes = String(format: "%02d", minutes)
        let formattedSeconds = String(format: "%02d", seconds)
        let description =  "\(formattedHours):\(formattedMinutes):\(formattedSeconds)"
        
        mainView.setCountdown(
            schedule: viewModel.schedule,
            countdownDesc: description
        )
    }
}

extension GiftBoxDetailViewController: GiftBoxViewDelegate {
    func didTapClose() {
        forceDismiss()
    }
    
    func didTapButton(state: GiftBoxInfoContainerView.ButtonState) {
        switch state {
        case .join:
            onJoin?(viewModel.id)
        case .follow:
            onFollow?(viewModel.accountId)
        default:
            break
        }
    }
}

// MARK: UI
private extension GiftBoxDetailViewController {
    func configureUI() {
        view.backgroundColor = .clear
        
        configureScrollContainer()
        configureBackgroundView()
        configureMainView()
    }
    
    private func configureScrollContainer() {
        view.addSubview(scrollContainer)
        scrollContainer.anchors.edges.pin()
    }
    
    func configureBackgroundView() {
        backgroundView.image = UIImage.LuckyDraw.giftBoxBackground
        backgroundView.contentMode = .scaleAspectFill
        
        scrollContainer.insertSubview(backgroundView, at: 0)
        backgroundView.anchors.edges.pin()
    }
    
    func configureMainView() {
        mainView.delegate = self
        scrollContainer.addArrangedSubViews(mainView)
    }
}

extension GiftBoxDetailViewController {
    struct ViewAdapter {
        let ownerFollow: GiftBoxOwnerFollowViewAdapter
        let join: GiftBoxJoinViewAdapter
        let detail: GiftBoxDetailViewAdapter
        
        fileprivate init(_ controller: GiftBoxDetailViewController) {
            self.ownerFollow = GiftBoxOwnerFollowViewAdapter(controller: controller)
            self.join = GiftBoxJoinViewAdapter(controller: controller)
            self.detail = GiftBoxDetailViewAdapter(controller: controller)
        }
    }
}
