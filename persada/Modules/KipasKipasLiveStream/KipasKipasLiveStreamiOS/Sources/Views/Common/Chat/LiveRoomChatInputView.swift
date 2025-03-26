import UIKit
import Combine
import KipasKipasShared

extension  Notification.Name {
    static let pushNotifForkeyboard = Notification.Name("pushNotifForkeyboard")
}

public final class LiveRoomChatInputView: UIView {
    
    private let tapView = UIView()
    private let container = UIView() 
    var deleteBtn = UIButton()
    
    var emojiInput: EmojiInputView = EmojiInputView(frame: .zero)  
     
    
    public var onTapSend: ((String) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var bottomConstraint: NSLayoutConstraint! {
        didSet {
            bottomConstraint.isActive = true
            updateConstraints()
        }
    }
    
    public override var isHidden: Bool {
        didSet {
            DispatchQueue.main.async {
                if self.isHidden {
                    self.emojiInput.textView.resignFirstResponder()
                } else {
                    self.emojiInput.textView.becomeFirstResponder()
                }
                let isShowDone = self.isHidden ? "yes":"no"
                NotificationCenter.default.post(name:.pushNotifForkeyboard , object: isShowDone)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureTapRecognizer()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
 
}

// MARK: UI
private extension LiveRoomChatInputView {
    func configureUI() { 
        isHidden = true
        setupTFView()
    }
    
    
    func setupTFView(){
        emojiInput.placeHolder = "Tambahkan komentar" 
        emojiInput.placeHolderColor = .gainsboro
        emojiInput.textFont = .roboto(.regular, size: 14)
        emojiInput.emojiReturnBlock = { [weak self] text in
            self?.onTapSend?(text) 
            self?.isHidden = true
        }
        
        emojiInput.viewHeightBlock = { [weak self] height in
            self?.bottomConstraint.constant = height
            self?.deleteBtn.isHidden = !(self?.emojiInput.emojiBtn.isSelected ?? false)
        }
        
        addSubview(emojiInput)
        emojiInput.anchors.leading.pin()
        emojiInput.anchors.trailing.pin()
        emojiInput.anchors.bottom.pin()
        
        deleteBtn.isHidden = true
        deleteBtn.backgroundColor = .white
        deleteBtn.setImage(.iconDeleteLeft)
        deleteBtn.layer.cornerRadius = 15
        deleteBtn.layer.borderWidth = 1
        deleteBtn.layer.borderColor = UIColor.softPeach.cgColor
        addSubview(deleteBtn)
        
        deleteBtn.anchors.width.equal(48)
        deleteBtn.anchors.height.equal(40)
        deleteBtn.anchors.bottom.pin(inset: 28)
        deleteBtn.anchors.trailing.pin(inset: 28)
        deleteBtn.onTap {
            self.emojiInput.textView.deleteBackward()
        }
    }
  
}

// MARK: Observer
private extension LiveRoomChatInputView {
    func configureTapRecognizer() {
        addSubview(container)
        container.anchors.top.pin()
        container.anchors.leading.pin()
        container.anchors.trailing.pin()
        bottomConstraint = container.anchors.bottom.pin()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapView))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        
        container.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTapView),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
    }
      
    @objc func onTapView() {
        isHidden = true
    }
      
}
