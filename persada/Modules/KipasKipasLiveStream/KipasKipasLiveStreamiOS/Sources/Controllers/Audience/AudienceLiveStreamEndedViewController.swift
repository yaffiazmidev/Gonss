import UIKit
import KipasKipasShared

final class AudienceLiveStreamEndedViewController: UIViewController {
    
    private let stackView = UIStackView()
    private let userImageView = UIImageView()
    private let label = UILabel()
    private let backButton = KKBaseButton()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = 50 / 2
        backButton.layer.cornerRadius = 40 / 2
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: API
    func setUserImage(_ source: String) {
        userImageView.setImage(with: source, placeholder: .defaultProfileImageCircle)
    }
}

// MARK: UI
private extension AudienceLiveStreamEndedViewController {
    func configureUI() {
        view.backgroundColor = .black
        configureStackView()
        configureBackButton()
    }
    
    func configureBackButton() {
        backButton.setBackgroundColor(UIColor.boulder.withAlphaComponent(0.3), for: .normal)
        backButton.setImage(.iconArrowLeft, for: .normal)
        backButton.clipsToBounds = true
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        view.addSubview(backButton)
        backButton.anchors.height.equal(40)
        backButton.anchors.width.equal(40)
        backButton.anchors.leading.pin(inset: 12)
        backButton.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top)
    }
    
    func configureStackView() {
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchors.center.align()
        
        configureUserImageView()
        configureLabel()
    }
    
    func configureUserImageView() {
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
        
        stackView.addArrangedSubview(userImageView)
        userImageView.anchors.width.equal(50)
        userImageView.anchors.height.equal(50)
    }
    
    func configureLabel() {
        label.text = "Live sudah berakhir"
        label.font = .roboto(.medium, size: 16)
        label.textColor = .white
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
    }
}
