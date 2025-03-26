import KipasKipasRegister
import KipasKipasShared

public typealias RegisterVerifyOTPLoader = AnyResourceLoader<RegisterVerifyOTPParam, RegisterVerifyOTPData>

struct RegisterVerifyOTPPresentationAdapter {
    
    typealias Controller = RegisterVerifyOTPViewController
    typealias PresentationAdapter = LoadResourcePresentationAdapter<RegisterVerifyOTPLoader, Controller>
    typealias Presenter = LoadResourcePresenter<RegisterVerifyOTPData, Controller>
    
    static func create(
        publisher: @escaping RegisterVerifyOTPLoader.LoadPublisher,
        controller: Controller
    ) -> PresentationAdapter {
        let loader = RegisterVerifyOTPLoader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: controller,
            loadingView: controller,
            errorView: controller,
            transformer:  {
                .init(isValid: $0.data.isRegister == false )
            }
        )
        
        presentationAdapter.presenter = presenter
        
        return presentationAdapter
    }
}

