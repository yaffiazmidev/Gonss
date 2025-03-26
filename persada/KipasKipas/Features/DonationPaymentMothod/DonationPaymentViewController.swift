import UIKit
import WebKit
import KipasKipasShared

final class DonationPaymentViewController: UIViewController {
    
    private lazy var webView = WKWebView()
    
    private var webViewURLObserver: NSKeyValueObservation?
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        
        configureUI()
        observe()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func observe() {
        webViewURLObserver = webView.observe(\.url, options: .new, changeHandler: { [weak self] webView, change in
            guard let self = self else { return }
            
            guard let newValue = change.newValue, let url = newValue else { return }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let queries = components?.queryItems ?? []
            
            if queries.contains(where: { ($0.name == "status_code" && ($0.value == "200"))}) {
                NotificationCenter.default.post(name: .updateDonationCampaign, object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    deinit {
        webViewURLObserver?.invalidate()
        webViewURLObserver = nil
    }
}

// MARK: UI
private extension DonationPaymentViewController {
    func configureUI() {
        configureWebView()
    }
    
    func configureWebView() {
        view.addSubview(webView)
        webView.anchors.edges.pin()
        
        webView.load(.init(url: url))
    }
}
