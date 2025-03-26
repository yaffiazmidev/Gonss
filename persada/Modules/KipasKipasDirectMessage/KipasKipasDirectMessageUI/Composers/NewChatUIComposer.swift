import UIKit
import KipasKipasDirectMessage

public enum NewChatUIComposer {
    public static func composeNewChatWith(
        userId: String,
        listFollowingLoader: @escaping (ListFollowingParam) -> ListFollowingLoader,
        searchUserLoader: @escaping (String) -> SearchAccountByUsernameLoader,
        completion: @escaping (TXIMUser) -> Void
    ) -> UIViewController {
        let listFollowingAdapter = ListFollowingInteractorAdapter(userId: userId, loader: listFollowingLoader)
        let searchUserAdapter = SearchUserInteractorAdapter(loader: searchUserLoader)
        
        let controller = NewChatViewController.loadFromNib()
        let presenter = NewChatPresenter(controller: controller)
        let interactor = NewChatInteractor(
            presenter: presenter,
            listFollowingAdapter: listFollowingAdapter,
            searchUserAdapter: searchUserAdapter
        )
        
        controller.interactor = interactor
        controller.completion = { user in
            DispatchQueue.main.async {
                controller.dismiss(animated: true) {
                    completion(user)
                }
            }
        }
        
        return controller
    }
}
