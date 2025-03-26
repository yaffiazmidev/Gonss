import UIKit

public enum LoadingViewType {
    case lineScalePulse
}

private extension LoadingViewType {
    var loadingView: KKLoadingView {
        switch self {
        case .lineScalePulse:
            return LineScalePulseIndicator()
        }
    }
}

public struct LoadingProperties {
    internal let type: LoadingViewType
    internal let color: UIColor
    internal let size: CGSize
    
    public init(
        type: LoadingViewType = .lineScalePulse,
        color: UIColor = .watermelon,
        size: CGSize = .init(width: 30, height: 30)
    ) {
        self.type = type
        self.color = color
        self.size = size
    }
}

public protocol LoadingViewable: AnyObject {
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

public class KKLoadingViewController: ContainerViewController, LoadingViewable {
    
    private var loadingView: KKLoadingView?
    
    public var onLoad: (() -> Void)?
    public var onDismiss: (() -> Void)?
    
    private let properties: LoadingProperties
    
    public init(properties: LoadingProperties = .init()) {
        self.properties = properties
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .night
        onLoad?()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
           onDismiss?()
        }
    }
    
    public func showLoadingIndicator() {
        loadingView = properties.type.loadingView
        
        if let loadingView = loadingView {
            loadingView.color = .watermelon
            loadingView.frame = .init(
                x: (view.bounds.width - properties.size.width) / 2,
                y: (view.bounds.height - properties.size.height) / 2,
                width: properties.size.width,
                height: properties.size.height
            )
            
            view.addSubview(loadingView)
           
            loadingView.startAnimating()
        }
    }
    
    public func hideLoadingIndicator() {
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}
