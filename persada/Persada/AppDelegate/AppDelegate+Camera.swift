import UIKit
import Combine
import KipasKipasShared
import KipasKipasCamera
import KipasKipasLiveStream
import KipasKipasStoryiOS
import IQKeyboardManagerSwift

var showCamerasViewController: ((@escaping (KKMediaItem) -> Void) -> Void)?
var showCameraPhotoViewController: ((@escaping (KKMediaItem) -> Void) -> Void)?
var showCameraPhotoVideoViewController: ((@escaping (KKMediaItem) -> Void) -> Void)?

extension AppDelegate {
    func configureCameraFeature() {
        KipasKipas.showCamerasViewController = showCamerasViewController
        KipasKipas.showCameraPhotoViewController = showCameraPhotoViewController
        KipasKipas.showCameraPhotoVideoViewController = showCameraPhotoVideoViewController
    }
    
    private func makeCameraContainerViewController(shouldShowLive: Bool, _ cameraHandler: @escaping (KKMediaItem) -> Void) -> UIViewController {
                
        let cameraPostController = CameraPostViewController()
        cameraPostController.didCaptureMedia = { [weak self] item in
            switch item.type {
            case .photo:
                cameraHandler(item)
            case .video:
                self?.window?.topViewController?.dismiss(animated: true) { [weak self] in
                    self?.showVideoPreview(with: item, completion: cameraHandler)
                }
            }
        }
        
        let storyCameraController = makeStoryCameraViewController(completion: cameraHandler)
        
        var models: [CamerasContainerViewController.OtherViewControllerModel] = [
            .init(viewController: cameraPostController, title: "Post", type: .post),
            .init(viewController: storyCameraController, title: "Story", type: .story),
        ]
        
        if shouldShowLive {
            models.append(.init(viewController: makeLiveStreamingAnchorViewController(), title: "Live", type: .live))
        }
        
        let controller = CamerasContainerViewController(models: models)
        controller.didSelectMediaItem = { [weak self] item in
            KKLogFile.instance.log(label:"AppDelegate", message: "didSelectMediaItem... \(item.type)")

            switch item.type {
            case .video:
                self?.showVideoPreview(with: item, completion: cameraHandler)
            case .photo:
                cameraHandler(item)
            }
        }
        
        cameraPostController.onSessionRunning = { [unowned controller] isRunning in
            if KKCache.common.readBool(key: .swipeGuideShowed) == false && isRunning {
                controller.configureSwipeGuideView {
                    KKCache.common.save(bool: true, key: .swipeGuideShowed)
                }
            }
        }
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        return controller
    }
    
    private func makeCameraPhotoVideoViewController(_ completion: @escaping (KKMediaItem) -> Void) -> UIViewController {
        let photoController = CameraPhotoViewController()
        photoController.didSelectMediaItem = completion
        
        let videoController = CameraVideoViewController()
       
        videoController.didSelectMediaItem = { [weak self] item in
            self?.window?.topViewController?.dismiss(animated: true) { [weak self] in
                self?.showVideoPreview(with: item, completion: completion)
            }
        }
        
        let controller = CamerasContainerViewController(
            models: [
                .init(viewController: photoController, title: "Foto", type: .post),
                .init(viewController: videoController, title: "Video", type: .post)
            ]
        )
        controller.didSelectMediaItem = completion
        return controller
    }
    
    private func makeStoryCameraViewController(completion: @escaping (KKMediaItem) -> Void) -> UIViewController {
        let storyCallback = StoryCameraUIComposer.Callback { [weak self] media in
            self?.window?.topViewController?.dismiss(animated: false) {
                completion(media)
            }
        }
        
        let controller = StoryCameraUIComposer.compose(
            profilePhoto: getPhotoURL(),
            callback: storyCallback
        )
        
        return controller
    }
    
    private final class LiveValidationAdapter {
        
        private let loader: () -> LiveValidationLoader
        
        private var cancellable: AnyCancellable?
        
        weak var loadingView: LoadingViewable?
        
        init(loader: @escaping () -> LiveValidationLoader) {
            self.loader = loader
        }
        
        func validate(completion: @escaping (Bool) -> Void) {
            loadingView?.showLoadingIndicator()
            
            cancellable = loader()
                .dispatchOnMainQueue()
                .delay(for: 0.5, scheduler: DispatchQueue.main)
                .handleEvents(
                    receiveOutput: { [weak self] _ in
                        self?.loadingView?.hideLoadingIndicator()
                    },
                    receiveCompletion: { [weak self] _ in
                        self?.loadingView?.hideLoadingIndicator()
                    }
                )
                .sink(receiveCompletion: { result in
                    if case .failure = result {
                        completion(false)
                    }
                }, receiveValue: { result in
                    let shouldShowLive = result.code == "1000"
                    completion(shouldShowLive)
                })
        }
    }
}

// MARK: Shared
extension AppDelegate {
    func showCamerasViewController(_ cameraHandler: @escaping (KKMediaItem) -> Void) {
        let adapter = LiveValidationAdapter(loader: makeLiveStreamValidationLoader)
        let loadingController = KKLoadingViewController()
        loadingController.modalPresentationStyle = .overFullScreen
        loadingController.onDismiss = {
            NotificationCenter.default.post(name: .shouldResumePlayer, object: nil)
        }
        
        adapter.loadingView = loadingController
        loadingController.onLoad = validate
        
        func validate() {
            adapter.validate { [weak self] shouldShowLive in
                guard let self = self else { return }
                let destination = makeCameraContainerViewController(shouldShowLive: shouldShowLive, cameraHandler)
                loadingController.transition(to: destination)
            }
        }
        
        NotificationCenter.default.post(name: .shouldPausePlayer, object: nil)
        
        presentOnce(loadingController)
    }
    
    func showCameraPhotoViewController(_ cameraHandler: @escaping (KKMediaItem) -> Void) {
        let cameraController = CameraPhotoViewController()
        cameraController.didSelectMediaItem = cameraHandler
        
        let destination = CameraViewController(cameraController: cameraController)
        destination.didSelectMediaItem = cameraHandler
        destination.modalPresentationStyle = .fullScreen

        presentOnce(destination)
    }
    
    func showCameraPhotoVideoViewController(_ completion: @escaping (KKMediaItem) -> Void) {
        let destination = makeCameraPhotoVideoViewController(completion)
        destination.modalPresentationStyle = .fullScreen
        
        presentOnce(destination)
    }
    
    func showVideoPreview(with item: KKMediaItem, completion: @escaping (KKMediaItem) -> Void) {
        KKLogFile.instance.log(label:"AppDelegate", message: "showVideoPreview")

        let destination = KKCameraPreviewViewController(item: item)
        destination.modalPresentationStyle = .fullScreen
        destination.modalTransitionStyle  = .crossDissolve
        destination.handleDoneTapped = {
            completion(item)
        }
        self.presentOnce(destination)
    }
}
