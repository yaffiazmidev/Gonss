import UIKit
import Combine
import KipasKipasShared

protocol AnchorPreLiveToolbarDelegate: AnyObject {
    func preliveDidLiveCancel()
    func preliveDidStartLive(roomName: String)
}

class AnchorPreLiveToolbarViewController: ToolbarContainerViewController {
    
    private var closeToolbar: AnchorPreLiveCloseToolbar!
    private var topToolbar: AnchorPreLiveTopToolbar!
    private var bottomToolbar: AnchorPreLiveBottomToolbar!
    
    private var cancellables: Set<AnyCancellable> = []
    
    weak var delegate: AnchorPreLiveToolbarDelegate?
    
    convenience init() {
        let closeToolbar = AnchorPreLiveCloseToolbar().height(40)
        let topToolbar = AnchorPreLiveTopToolbar().height(60)
        let bottomToolbar = AnchorPreLiveBottomToolbar().height(40)
        
        self.init(topToolbars: [closeToolbar, topToolbar], bottomToolbars: [bottomToolbar])
        self.closeToolbar = closeToolbar
        self.topToolbar = topToolbar
        self.bottomToolbar = bottomToolbar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapView))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
        
        let closeButtonPublisher = closeToolbar.closeButton.tapPublisher
        let startLiveButtonPublisher = bottomToolbar.startLiveButton.tapPublisher
        
        topToolbar.roomTitleTextView.delegate = self
        
        closeButtonPublisher
            .sink { [weak self] in
                self?.dismiss(animated: true)
                self?.delegate?.preliveDidLiveCancel()
            }
            .store(in: &cancellables)
        
        startLiveButtonPublisher
            .sink { [weak self] in
                if let roomName = self?.topToolbar.roomTitleTextView.text, !roomName.isEmpty {
                    self?.delegate?.preliveDidStartLive(roomName: roomName)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: API
    func setUserPhoto(_ source: String?) {
        topToolbar.setUserPhoto(source)
    }
    
    @objc private func onTapView() {
        topToolbar.roomTitleTextView.resignFirstResponder()
    }
}

extension AnchorPreLiveToolbarViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        topToolbar.editingButton.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
        topToolbar.editingButton.isHidden = false
        bottomToolbar.startLiveButton.isEnabled = text.isEmpty == false
    }
}

