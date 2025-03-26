
import UIKit
import WebKit
import KipasKipasShared

final class NewsPortalWebViewController: UIViewController {
    
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
        view.backgroundColor = .black
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
}

// MARK: UI
private extension NewsPortalWebViewController {
    func configureUI() {
        configureWebView()
    }
    
    func configureWebView() {
        view.addSubview(webView)
        webView.fillSuperviewSafeAreaLayoutGuide()
        
        webView.load(.init(url: url))
    }
}
