import UIKit
import KipasKipasShared
import KipasKipasCamera

public protocol StoryPostDelegate: AnyObject {
    func didPostStory(with media: KKMediaItem, info: Any?)
}

public final class StoryPrePostViewController: UIViewController {
    
    private let backButton = KKBaseButton()
    
    private let stackContainer = UIStackView()
    private let previewView = UIView()
    private let menuView = StoryPreviewMenu()
    private let bottomView = UIView()
    private let postButton = StoryPostButton()
    
    public weak var delegate: StoryPostDelegate?
    public var info: Any?
    
    // MARK: Editing
    public var editor: StoryEditor!
    
    private let profilePhoto: URL?
    
    public init(
        profilePhoto: URL?
    ) {
        self.profilePhoto = profilePhoto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: Lifecycles
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .night
        
        configureUI()
        configureEditor()
    }
    
    // MARK: Helpers
    private func configureEditor() {
        add(
            childViewController: editor.toPresentable(),
            targetView: previewView,
            sendViewToBack: true
        )
    }
    
    @objc private func didTapBack() {
        dismiss(animated: false)
    }
    
    @objc private func didTapPost() {
        KKDefaultLoading.shared.show()
        editor.exportMedia { [weak self] media in
            KKDefaultLoading.shared.hide()
            self?.dismiss(animated: true) { [weak self] in
                self?.delegate?.didPostStory(with: media, info: self?.info)
            }
        }
    }
    
    private func setEditingMode(_ isEditingMode: Bool) {
        menuView.isHidden = isEditingMode
        backButton.isHidden = isEditingMode
    }
}

// MARK: StoryPreviewMenuDelegate
extension StoryPrePostViewController: StoryPreviewMenuDelegate {
    func didTapText() {
        editor.switchToTextEditingMode(editingTextView: nil)
    }
    
    func didTapSave() {
       editor.saveMedia()
    }
}

extension StoryPrePostViewController: StoryEditorDelegate {
    public func didEnterEditingMode() {
        setEditingMode(true)
    }
    
    public func didExitEditingMode() {
        setEditingMode(false)
    }
}

// MARK: UI
private extension StoryPrePostViewController {
    func configureUI() {
        configureStackContainer()
        configurePreviewView()
        configureBottomView()
        configurePostStoryButton()
        configurePreviewLeftPanelView()
        configureBackButton()
    }
    
    func configureStackContainer() {
        stackContainer.axis = .vertical
        
        view.addSubview(stackContainer)
        stackContainer.anchors.top.pin(to: view.safeAreaLayoutGuide)
        stackContainer.anchors.edges.pin(axis: .horizontal)
        stackContainer.anchors.bottom.pin()
    }
    
    func configurePreviewView() {
        previewView.backgroundColor = .clear
        previewView.layer.cornerRadius = 16
        previewView.clipsToBounds = true
        
        stackContainer.addArrangedSubview(previewView)
    }
    
    private func configureBottomView() {
        bottomView.backgroundColor = .night
        
        stackContainer.addArrangedSubview(bottomView)
        bottomView.anchors.height.equal(92)
    }
    
    private func configurePostStoryButton() {
        postButton.photoURL = profilePhoto
        postButton.layer.cornerRadius = 8
        postButton.backgroundColor = .white
        postButton.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        
        bottomView.addSubview(postButton)
        postButton.anchors.height.equal(40)
        postButton.anchors.edges.pin(insets: 20, axis: .horizontal)
        postButton.anchors.center.align()
    }
    
    func configureBackButton() {
        backButton.setImage(.iconChevronLeft?.withTintColor(.white))
        backButton.backgroundColor = UIColor.night.withAlphaComponent(0.2)
        backButton.clipsToBounds = true
        backButton.layer.cornerRadius = 40 / 2
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        previewView.addSubview(backButton)
        backButton.anchors.width.equal(40)
        backButton.anchors.height.equal(40)
        backButton.anchors.top.pin(inset: 12)
        backButton.anchors.leading.pin(inset: 12)
    }
    
    func configurePreviewLeftPanelView() {
        menuView.backgroundColor = .clear
        menuView.delegate = self
        
        previewView.addSubview(menuView)
        menuView.anchors.width.equal(40)
        menuView.anchors.top.pin(inset: safeAreaInsets.top)
        menuView.anchors.trailing.pin(inset: 12)
        menuView.anchors.bottom.pin()
    }
}
