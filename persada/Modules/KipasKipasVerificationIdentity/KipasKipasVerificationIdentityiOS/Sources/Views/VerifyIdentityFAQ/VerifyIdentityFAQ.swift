import UIKit
import WebKit
import KipasKipasShared

public class VerifyIdentityFAQView: UIView {
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .white
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        addSubview(webView)
        webView.anchors.edges.pin(insets: UIEdgeInsets(top: 16, left: 0, bottom: -20, right: 0))
        
        //        let url = Bundle.main.url(forResource: "faq-verify-identity", withExtension: "html")!
        //        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: URL(string: "https://test-web.kipaskipas.com/faq-verify")!)
        webView.load(request)
    }
}

extension VerifyIdentityFAQView: WKNavigationDelegate {}
