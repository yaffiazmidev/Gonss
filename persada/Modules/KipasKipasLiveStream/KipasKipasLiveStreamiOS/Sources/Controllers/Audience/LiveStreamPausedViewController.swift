import UIKit
import KipasKipasShared

final class LiveStreamPausedViewController: UIViewController {
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private var numberOfDots = 3
    
    private lazy var stopwatch = Stopwatch(timeUpdated: { [weak self] _ in
        self?.showLoading()
    })
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stopwatch.toggle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopwatch.stop()
    }
    
    private func showLoading() {
        if let text = descriptionLabel.text {
            let range = NSMakeRange(text.count - numberOfDots, numberOfDots)
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: range)
            
            descriptionLabel.attributedText = attributedString
            numberOfDots -= 1
            
            if numberOfDots < 0 {
                numberOfDots = 3
            }
        }
    }
}

// MARK: UI
private extension LiveStreamPausedViewController {
    func configureUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isUserInteractionEnabled = false
        configureStackView()
    }
    
    func configureStackView() {
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 7
        
        view.addSubview(stackView)
        stackView.anchors.center.align()
        
        configureTitleLabel()
        configureDescriptionLabel()
    }
    
    func configureTitleLabel() {
        titleLabel.text = "Live terjeda"
        titleLabel.font = .roboto(.medium, size: 14)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.text = "Menyambungkan ulang..."
        descriptionLabel.font = .roboto(.regular, size: 12)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        stackView.addArrangedSubview(descriptionLabel)
    }
}
