import UIKit
import KipasKipasShared

public final class LiveStreamingEmptyListViewController: UIViewController {
    
    /// Using fake navbar to (temporarily) prevent glitch when using embedded navigation bar
    /// in parent view controller
    private let fakeNavbar = FakeNavBar()
    
    private let container = ScrollContainerView()
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: UI
private extension LiveStreamingEmptyListViewController {
    func configureUI() {
        view.backgroundColor = .black
        view.addSubview(container)
        
        configureFakeNavbar()
        configureContainer()
    }
    
    func configureContainer() {
        container.spacingBetween = 32
        container.isCentered = true
        container.alignment = .center
        
        container.anchors.top.spacing(0, to: fakeNavbar.anchors.bottom)
        container.anchors.edges.pin(axis: .horizontal)
        container.anchors.bottom.pin()
        
        configureImageView()
        configureDescriptionLabel()
    }
    
    func configureImageView() {
        imageView.image = .illustrationVideoCamera
        container.addArrangedSubViews(imageView)
        
        imageView.anchors.width.equal(124)
        imageView.anchors.height.equal(124)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.font = .roboto(.medium, size: 12)
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "Belum ada live streaming yang bisa kamu nikmati, daripada menunggu, ayo mulai live mu sendiri"
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 2

        container.addArrangedSubViews(descriptionLabel)
        descriptionLabel.anchors.width.equal(view.bounds.width * 0.740)
    }
    
    func configureFakeNavbar() {
        fakeNavbar.backgroundColor = .night
        fakeNavbar.height = 41
        fakeNavbar.separatorView.backgroundColor = .clear
        fakeNavbar.leftButton.setImage(.iconArrowLeft)
        fakeNavbar.leftButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        view.addSubview(fakeNavbar)
    }
    
    @objc func didTapBack() {
        parent?.navigationController?.popViewController(animated: true)
    }
}
