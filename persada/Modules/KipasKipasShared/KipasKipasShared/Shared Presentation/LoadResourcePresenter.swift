import Foundation

public protocol ResourceView: AnyObject {
    associatedtype ResourceViewModel
    func display(view viewModel: ResourceViewModel)
}

public protocol ResourceLoadingView: AnyObject {
    func display(loading loadingViewModel: ResourceLoadingViewModel)
    func shouldHideLoadingWhenResourceReceived() -> Bool
}

public extension ResourceLoadingView {
    func display(loading loadingViewModel: ResourceLoadingViewModel) {}
    func shouldHideLoadingWhenResourceReceived() -> Bool {
        return true
    }
}

public protocol ResourceErrorView: AnyObject {
    func display(error errorViewModel: ResourceErrorViewModel)
}

public extension ResourceErrorView {
    func display(error errorViewModel: ResourceErrorViewModel) {}
}

public struct AnyError: Error {
    
    public let code: String
    public let message: String?
    public let data: Data?
    
    public init(code: String, message: String? = nil, data: Data? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
    
    public func decodeError<T: Decodable>() -> T? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

public final class ViewAdapter<Model>: ResourceView, ResourceErrorView {
    
    public var delegate: Closure<Model>?
    public var delegateError: Closure<ResourceErrorViewModel>?
    
    public init() {}
    
    public func display(view viewModel: Model) {
        delegate?(viewModel)
    }
    
    public func display(error errorViewModel: ResourceErrorViewModel) {
        delegateError?(errorViewModel)
    }
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    
    public typealias Transformer = (Resource) throws -> View.ResourceViewModel
    
    private weak var view: View?
    private weak var loadingView: ResourceLoadingView?
    private weak var errorView: ResourceErrorView?
    private let transformer: Transformer
    
    public init(
        view: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView,
        transformer: @escaping Transformer
    ) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        self.transformer = transformer
    }
    
    public init(view: View) where Resource == View.ResourceViewModel {
        self.view = view
        self.loadingView = view as? ResourceLoadingView
        self.errorView = view as? ResourceErrorView
        self.transformer = { $0 }
    }
    
    public init(
        view: View,
        transformer: @escaping Transformer
    ) {
        self.view = view
        self.loadingView = view as? ResourceLoadingView
        self.errorView = view as? ResourceErrorView
        self.transformer = transformer
    }

    public func didStartLoading() {
        loadingView?.display(loading: .init(isLoading: true))
    }
    
    public func didFinishLoading(with response: Resource) {
        do {
            if loadingView?.shouldHideLoadingWhenResourceReceived() == true {
                loadingView?.display(loading: .init(isLoading: false))
            }
            
            view?.display(view: try transformer(response))
            
        } catch {
            if let error = error as? AnyError {
                didFinishLoading(withError: error)
            } else {
                didFinishLoading(withError: .init(code: "0000", message: "Default"))
            }
        }
    }
    
    public func didFinishLoading(withError error: AnyError) {
        loadingView?.display(loading: .init(isLoading: false))
        errorView?.display(error: .init(error: error))
    }
}
