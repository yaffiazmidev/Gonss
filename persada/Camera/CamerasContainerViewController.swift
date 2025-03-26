import UIKit
import AVFoundation
import Combine
import KipasKipasShared
import KipasKipasCamera
import CoreServices
import Lottie
import KipasKipasCall
import IQKeyboardManagerSwift
import KipasKipasStoryiOS

extension  Notification.Name {
    static let pushNotifForLiveStart = Notification.Name("pushNotifForLiveStart")
}

public final class CamerasContainerViewController: UIViewController, UINavigationControllerDelegate {
    
    public struct OtherViewControllerModel {
        public let viewController: UIViewController
        public let title: String
        public let type: ControllerType
        
        public init(viewController: UIViewController, title: String, type: ControllerType) {
            self.viewController = viewController
            self.title = title
            self.type = type
        }
    }
    
    /// An enum for defining the orders
    public enum ControllerType: Int {
        case post
        case story
        case live
    }
    
    private lazy var pagingViewController = CameraPagingViewController()
    private lazy var mediaPickerController = {
        let picker = KKMediaPicker()
        picker.delegate = self
        picker.types = [.photo, .video]
        return picker
    }()
    
    private var selectedControllerType: ControllerType = .post
    
    private var controllers: [UIViewController] = []
    private var items: [PagingItem] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    public var didSelectMediaItem: ((KKMediaItem) -> Void)?
    
    private let models: [OtherViewControllerModel]
    
    public init(models: [OtherViewControllerModel]) {
        self.models = models
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        checkStorageCapacity()
        
        setData()
        configureUI()
        observe()
        addObserver()
    }
    
    private func setData() {
        /// Ensure to sort it as the order on enum
        let sorted = models.sorted(by: { $0.type.rawValue < $1.type.rawValue })
        
        controllers = sorted.map { $0.viewController }
        items += sorted.map { PagingIndexItem(
            index: $0.type.rawValue,
            title: $0.title
        )}
    }
    
    
    @objc func liveStart(){
        let liveItem:OtherViewControllerModel = models.last!
        controllers = [liveItem.viewController]
        items = [PagingIndexItem(index: liveItem.type.rawValue, title: liveItem.title)]
        
        pagingViewController.reloadData()
    }
    
    func addObserver(){
        NotificationCenter.default.addObserver(
                    self, selector: #selector(liveStart),
                    name:.pushNotifForLiveStart, object: nil
                )
    }
    
    private func observe() {
        pagingViewController.mainView.rotateButton
            .tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                if let controller = selectedViewController() as? CameraBaseViewController {
                    controller.switchCamera()
                }
            }
            .store(in: &cancellables)
        
        TUICallStateViewModel.shared.$isLiving
            .sink(receiveValue: { [weak self] isLiving in
                DispatchQueue.main.async {
                    self?.pagingViewController.pageViewController.scrollView.isScrollEnabled = isLiving == false
                } 
            })
            .store(in: &cancellables)
                
        pagingViewController.mainView.photoView
            .tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                pickImage()
            }
            .store(in: &cancellables)
        
        fetchPhotos()
    }
    
    private func fetchPhotos() {
        Task {
            let images = try? await MediaLibraryFetcher.fetchPhotos(targetSize: .init(width: 200, height: 200))
            pagingViewController.mainView.photoView.setImage(images?.first)
        }
    }
    
    private func checkStorageCapacity() {
        let freeDiskSpaceInBytes_MB = UIDevice.current.freeDiskSpaceInBytes / 1_000_000
        let MIN_FREE_IN_MB = 100
        
        KKLogFile.instance.log(label:"CamerasContainerViewController", message: "freeDiskSpaceInBytes_MB: \(freeDiskSpaceInBytes_MB), minimunFreeInMB:\(MIN_FREE_IN_MB)")
        
        let isLessThanMinimumSpace = freeDiskSpaceInBytes_MB <= MIN_FREE_IN_MB
        
        if(isLessThanMinimumSpace){
            DispatchQueue.main.async {
                let okAction = UIAlertAction(title: "OK", style: .destructive)
                self.showAlertController(title: "Storage almost full", message: "Please cleaned up your storage ",  actions: [okAction])
            }
        }
    }

    
    private func pickImage() {
        Task {
            let status = await MediaLibraryFetcher.getAuthorizationStatus()
            
            if status == .authorized {
                mediaPickerController.videoMaxDuration = selectedControllerType == .story ? storyVideoMaxDuration : nil
                mediaPickerController.show(in: self)
            } else {
                let settings = UIAlertAction(
                    title: "Pengaturan",
                    style: .default,
                    handler: { _ in UIViewController.openSettings() }
                )
                settings.titleTextColor = .night
                
                let cancel = UIAlertAction(title: "Batal", style: .destructive)
                
                showAlertController(
                    title: "Akses galeri tidak diizinkan",
                    titleFont: .roboto(.bold, size: 18),
                    message: "\nUntuk mengakses foto/video di galeri kamu, akses galeri harus diizinkan. \n\nKamu bisa mengubah izin akses galeri di pengaturan.\n",
                    messageFont: .roboto(.regular, size: 14),
                    backgroundColor: .white,
                    actions: [settings, cancel]
                )
            }
        }
    }
    
    private func selectedViewController() -> UIViewController? {
        return pagingViewController.pageViewController.selectedViewController
    }
    
    func configureSwipeGuideView(completion: @escaping () -> Void) {
        let animation = LottieAnimation.named("swipe-left")
        let animationView = LottieAnimationView(animation: animation)
        animationView.frame = view.bounds
        animationView.backgroundColor = .clear
        animationView.loopMode = .repeat(2)
        
        view.addSubview(animationView)
        
        animationView.layoutIfNeeded()
        animationView.play { _ in
            UIView.animate(withDuration: 0.2, animations: {
                animationView.alpha = 0
                animationView.stop()
            }, completion: { _ in
                animationView.removeFromSuperview()
                completion()
            })
        }
    }
    
    deinit {
        controllers.removeAll()
    }
}

// MARK: UI
private extension CamerasContainerViewController {
    func configureUI() {
        view.backgroundColor = .night
        configurePagingViewController()
    }
    
    func configurePagingViewController() {
        pagingViewController.menuPosition = .bottom
        pagingViewController.selectedScrollPosition = models.count > 2 ? .center : .preferCentered
        pagingViewController.contentInteraction = .scrolling
        pagingViewController.menuInteraction = .swipe
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        pagingViewController.textColor = UIColor.white.withAlphaComponent(0.6)
        pagingViewController.selectedTextColor = .white
        pagingViewController.indicatorColor = .white
        pagingViewController.indicatorOptions = .hidden
        pagingViewController.menuBackgroundColor = .night
        pagingViewController.register(PagingTitleCell.self, for: PagingIndexItem.self)
        pagingViewController.menuItemSize = .selfSizing(estimatedWidth: 100, height: 94)
        pagingViewController.borderOptions = .hidden
        pagingViewController.menuHorizontalAlignment = .center
        pagingViewController.animateContentOnSelect = false

        add(pagingViewController)
    }
}

// MARK: UIImagePickerControllerDelegate
extension CamerasContainerViewController: KKMediaPickerDelegate {
    public func didPermissionRejected() {
        KKMediaPicker.showAlertForAskPhotoPermisson(in: self)
    }
    
    public func didLoading(isLoading: Bool) {        
        KKLogFile.instance.log(label:"CamerasContainerViewController", message: "didLoading")
        if isLoading {
            KKLoading.shared.show()
        } else {
            KKLoading.shared.hide()
        }
    }
    
    public func didSelectMedia(media item: KKMediaItem) {
        if selectedControllerType == .story {
            if let controller = selectedViewController() as? StoryCameraViewController {
                switch item.type {
                case .photo:
                    guard let data = item.data else { return }
                    controller.showStoryPhotoPreview(with: UIImage(data: data))
                case .video:
                    let videoURL = URL(string: item.path)
                    controller.showStoryVideoPreview(videoURL: videoURL)
                }
            }
        } else {
            self.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                didSelectMediaItem?(item)
            }
        }
    }
    
    public func videoNeedTrim(url: URL) {
        Toast.share.show(message: "Maksimal durasi 3 menit", backgroundColor: .init(hexString: "4A4A4A"), cornerRadius: 8)
    }
}

// MARK: PagingViewControllerDataSource
extension CamerasContainerViewController: PagingViewControllerDataSource {
    public func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return controllers[index]
    }
    
    public func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return items[index]
    }
    
    public func numberOfViewControllers(in _: PagingViewController) -> Int {
        return controllers.count
    }
}

extension CamerasContainerViewController: PagingViewControllerDelegate {
    public func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        guard let item = pagingItem as? PagingIndexItem,
              let type = ControllerType(rawValue: item.index) else { return }
        
        selectedControllerType = type
        
        self.pagingViewController.hideBottomBar(type == .live)
    }
    
    
    public func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        guard let item = pagingItem as? PagingIndexItem,
              let type = ControllerType(rawValue: item.index) else { return }
        
        selectedControllerType = type
        
        self.pagingViewController.hideBottomBar(type == .live)
    }
}
