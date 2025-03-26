import UIKit
import KipasKipasShared
import KipasKipasStory
import KipasKipasStoryiOS
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var dummy = DummyViewController()
    
    private(set) lazy var navigationController = UINavigationController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        UIFont.loadCustomFonts
        UIView.swizzleLayoutSubviews()
        try? VideoCacheManager.cleanAllCache()
        
        dummy.showListStory = { [weak self] in
            self?.showViewingListController()
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        navigationController.setViewControllers([dummy], animated: true)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

final class DummyViewController: UIViewController {
    
    var showListStory: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showListStory?()
    }
}

// MARK: Helpers
private extension SceneDelegate {
    func makeListDemoViewController() -> UIViewController {
        let controller = ListDemoViewController(selection: handleSelection)
        controller.title = "Story Demo"
        return controller
    }
    
    func handleSelection(fromType type: String) {
        guard let demoType = StoryDemoType(rawValue: type) else { return }
        
        switch demoType {
        case .cameraStory:
            let destination = makeStoryCameraViewController()
            navigationController.pushViewController(destination, animated: false)
            
        case .createStory:
            print("Go to the {\(demoType)} demo view controller")
            
        case .detailStory:
            print("Go to the {\(demoType)} demo view controller")
            
        case .listStory:
            print("Go to the {\(demoType)} demo view controller")
        }
    }
    
    private func makeStoryViewingListController() -> UIViewController {
        let parameter = StoryViewingListUIComposer.Parameter(
            selectedId: "",
            viewModels: storyMocks
        )
        let callback = StoryViewingListUIComposer.Callback(
            showListViewers: {
                print("[BEKA] show list viewers", $0)
            },
            showShareSheet: {
                print("[BEKA] show share sheet", $0)
            },
            showCameraGallery: {},
            showProfile: { _ in }
        )
        let loader = StoryViewingListUIComposer.Loader(
            storySeenLoader: StorySeenLoader(publisher: makeStorySeenLoader),
            storyLikeLoader: StoryLikeLoader(publisher: makeStoryLikeLoader),
            storyDeleteLoader: StoryDeleteLoader(publisher: makeStoryDeleteLoader)
        )
        let controller = StoryViewingListUIComposer.composeWith(
            parameter: parameter,
            callback: callback,
            loader: loader
        )
        return controller
    }
    
    private func makeStorySeenLoader(_ param: StorySeenRequest) -> API<StoryEmptyData, AnyError> {
        let output: Result<StoryEmptyData, AnyError> = .success(.init(code: "1002", message: "Message"))
        return .init(output.publisher)
            .eraseToAnyPublisher()
    }
    
    private func makeStoryLikeLoader(_ param: StoryLikeRequest) -> API<StoryEmptyData, AnyError> {
        let output: Result<StoryEmptyData, AnyError> = .success(.init(code: "1000", message: "Message"))
        return .init(output.publisher)
            .eraseToAnyPublisher()
    }
    
    private func makeStoryDeleteLoader(_ param: StoryDeleteRequest) -> API<StoryEmptyData, AnyError> {
        let output: Result<StoryEmptyData, AnyError> = .success(.init(code: "1000", message: "Message"))
        return .init(output.publisher)
            .eraseToAnyPublisher()
    }
    
    private func makeStoryCameraViewController() -> UIViewController {
        return StoryCameraUIComposer.compose(
            profilePhoto: "https://asset.kipaskipas.com/img/media/1714817946606.jpeg",
            callback: .init(didPostStory: { _ in })
        )
    }
    
    // MARK: StoryViewers
    private func makeStoryViewersViewController() -> UIViewController {
        let parameter = StoryViewersUIComposer.Parameter(storyId: "1234")
        let loader = StoryViewersUIComposer.Loader(
            viewersLoader: StoryViewersLoader(publisher: makeStoryViewersLoader), 
            followLoader: StoryFollowLoader(publisher: makeStoryFollowLoader)
        )
        let callback = StoryViewersUIComposer.Callback(
            didDeleteStory: {
            print("[BEKA] delete story", parameter)
        }, showProfile: {
            print("[BEKA] show profile", $0)
        }, sendMessage: {
            print("[BEKA] send message", $0)
        })
        
        let controller = StoryViewersUIComposer.composeWith(
            parameter: parameter,
            loader: loader, 
            callback: callback
        )
        return controller
    }
    
    private func navigateToStoryViewersViewController() {
        let destination = makeStoryViewersViewController()
        navigationController.pushViewController(destination, animated: true)
    }
    
    private func makeStoryViewersLoader(_ param: StoryViewerRequest) -> API<StoryViewersResponse, AnyError> {
        let output: Result<StoryViewersResponse, AnyError> = .success(.mock(isEmpty: false))
        return .init(output.publisher)
            .eraseToAnyPublisher()
    }
    
    private func makeStoryFollowLoader(_ userId: String) -> API<StoryEmptyData, AnyError> {
        let output: Result<StoryEmptyData, AnyError> = .success(.init(code: "1000", message: "General success"))
        return .init(output.publisher)
            .eraseToAnyPublisher()
    }
    
    private func makeStoryUnfollowLoader(_ userId: String) -> API<StoryEmptyData, AnyError> {
        let output: Result<StoryEmptyData, AnyError> = .success(.init(code: "1000", message: "General success"))
        return .init(output.publisher)
            .eraseToAnyPublisher()
    }
}

// MARK: - List Story
fileprivate extension SceneDelegate {
    func showViewingListController() {
        let listStory = makeStoryViewingListController()
        listStory.modalPresentationStyle = .fullScreen
        dummy.present(listStory, animated: false)
    }
}
