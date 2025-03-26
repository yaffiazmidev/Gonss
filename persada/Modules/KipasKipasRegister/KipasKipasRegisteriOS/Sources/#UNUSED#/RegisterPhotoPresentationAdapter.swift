import UIKit
import KipasKipasRegister
import KipasKipasShared

public typealias RegisterPhotoUploader = AnyResourceLoader<RegisterUploadPhotoParam, String>

enum RegisterPhotoPresentationAdapter {
    typealias Controller = RegisterPhotoViewController
    typealias PresentationAdapter = LoadResourcePresentationAdapter<RegisterPhotoUploader, Controller>
    typealias Presenter = LoadResourcePresenter<String, Controller>
    
    static func create(
        publisher: @escaping RegisterPhotoUploader.LoadPublisher,
        view: Controller
    ) -> PresentationAdapter {
        let loader = RegisterPhotoUploader(publisher: publisher)
        let presentationAdapter = PresentationAdapter(loader: loader)
        let presenter = Presenter(
            view: view,
            transformer: { .init(url: $0) }
        )
        presentationAdapter.presenter = presenter
        return presentationAdapter
    }
}
