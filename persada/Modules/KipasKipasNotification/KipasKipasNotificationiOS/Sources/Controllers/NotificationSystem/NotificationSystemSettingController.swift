import UIKit
import KipasKipasShared
import KipasKipasNotification

public class NotificationSystemSettingController: UIViewController {
    private var mainView: NotificationSystemSettingView = NotificationSystemSettingView(frame: .zero)
    private var types = ["hotroom", "live", "account"]
    
    private let preferencesLoader: NotificationPreferencesLoader
    private let preferencesUpdater: NotificationPreferencesUpdater
    
    public init(preferencesLoader: NotificationPreferencesLoader, preferencesUpdater: NotificationPreferencesUpdater) {
        self.preferencesLoader = preferencesLoader
        self.preferencesUpdater = preferencesUpdater
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view = mainView
        configureUI()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Helper
private extension NotificationSystemSettingController {
   
    private func configureCollectionView() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
    }
    
    private func configureUI() {
        view.backgroundColor = .whiteSmoke
        UIFont.loadCustomFonts
        configureCollectionView()
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "System Notification"
        navigationController?.navigationBar.barTintColor = .whiteSmoke
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backgroundColor = .whiteSmoke
        
        let leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
}

extension NotificationSystemSettingController: UIGestureRecognizerDelegate {}

// MARK: - CollectionView Flow Delegate
extension NotificationSystemSettingController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! NotificationSystemSettingItemCell
        let index = types[indexPath.row]
        cell.configure(types: index)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height = 50
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableHeader(at: indexPath)
        
        let label = UILabel()
        label.font = .roboto(.medium, size: 12)
        label.textColor = .grey
        label.text = "Channel"
        
        header.addSubview(label)
        label.frame = CGRect(x: 16, y: 0, width: collectionView.bounds.width, height: 40)
        
        return header
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = types[indexPath.row]
        let viewModel = SystemSettingTypesViewModel(preferencesLoader: preferencesLoader, preferencesUpdater: preferencesUpdater)
        let controller = SystemSettingTypesController(type: type, viewModel: viewModel)
        viewModel.delegate = controller
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: false)
    }
}
