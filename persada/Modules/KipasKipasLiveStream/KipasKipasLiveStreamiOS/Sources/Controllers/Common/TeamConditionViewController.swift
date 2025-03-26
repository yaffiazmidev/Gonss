import Foundation
import UIKit
import WebKit
import KipasKipasTRTC
import KipasKipasLiveStream
import KipasKipasShared

public final class TeamConditionViewController: UIViewController,UICollectionViewDelegate{
    private lazy var webContentV = UIScrollView()
    private var web: WKWebView?
    private let retryBtn: UIButton = UIButton(type: .custom)
    var pageUrl: String = "https://kipaskipas.com/syarat-dan-ketentuan-kipaskipas/#1708505304969-d5c70f6e-7779"
    
    #warning("[BEKA] move this to a protocol or extension")
    private var panNavigation: (UIViewController & PanModalPresentable)? {
        return navigationController as? (UIViewController & PanModalPresentable)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI() {
        self.title = "T&C"
        let web = WKWebView() 
        self.view.addSubview(web)
        web.anchors.edges.pin()
        self.web = web
        
        
        retryBtn.setTitle("retry", for: .normal)
        retryBtn.setTitleColor(.black, for: .normal)
        retryBtn.addTarget(self, action: #selector(reloadWebData), for: .touchUpInside)
        self.view.addSubview(retryBtn)
        retryBtn.anchors.centerY.align()
        retryBtn.anchors.centerX.align()
        retryBtn.isHidden = true
        
        self.reloadWebData()
    
    }
    
    @objc private func reloadWebData() {
            self.web?.load(URLRequest(url: URL(string: pageUrl)!))
    }
}

// MARK: PanModal
extension TeamConditionViewController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        return webContentV
    }
    
//    public var panScrollable: UIScrollView? {
//        collectionView
//    }
    
    public var longFormHeight: PanModalHeight {
        .contentHeight(420)
    }
    
    public var shortFormHeight: PanModalHeight {
        longFormHeight
    }
    
    public var panModalBackgroundColor: UIColor {
        .clear
    }
}
