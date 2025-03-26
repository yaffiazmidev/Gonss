import UIKit
import WebKit

open class ProgressWebViewController: UIViewController, NavigationAppearance {
    
    private lazy var webView = WKWebView()
    
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    private let url: URL?
    
    public init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: title ?? "")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        webView.backgroundColor = .white
        
        configureWebView()
        configureProgressView()
        configureProgressObserver()
        
        if let url = url{
            setupWebview(url: url)
        }
    }
    
    // MARK: - Private methods
    private func configureWebView() {
        view.addSubview(webView)
        webView.anchors.edges.pin()
    }
    
    private func configureProgressView() {
        guard let navigationBar = navigationController?.navigationBar else {
            print("⚠️ – Expected to have a valid navigation controller at this point.")
            return
        }
        
        progressView.isHidden = true
        progressView.trackTintColor = .ashGrey
        progressView.progressTintColor = .watermelon
        
        navigationBar.addSubview(progressView)
        progressView.anchors.edges.pin(axis: .horizontal)
        progressView.anchors.bottom.pin()
        progressView.anchors.height.equal(2)
    }
    
    private func configureProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    private func setupWebview(url: URL) {
        webView.navigationDelegate = self
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate
extension ProgressWebViewController: WKNavigationDelegate {
    public func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        if progressView.isHidden {
            // Make sure our animation is visible.
            progressView.isHidden = false
        }
        
        UIView.animate(
            withDuration: 0.33,
            animations: {
                self.progressView.alpha = 1.0
            })
    }
    
    public func webView(_: WKWebView, didFinish _: WKNavigation!) {
        UIView.animate(
            withDuration: 0.33,
            animations: {
                self.progressView.alpha = 0.0
            },
            completion: { isFinished in
                // Update `isHidden` flag accordingly:
                //  - set to `true` in case animation was completly finished.
                //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                self.progressView.isHidden = isFinished
            })
    }
}
