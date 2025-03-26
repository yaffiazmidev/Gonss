import UIKit
import KipasKipasShared

typealias AnchorPreLiveCloseToolbar = AnchorPreLiveToolbar.CloseToolbar
typealias AnchorPreLiveTopToolbar = AnchorPreLiveToolbar.TopToolbarView
typealias AnchorPreLiveBottomToolbar = AnchorPreLiveToolbar.BottomToolbarView

// MARK: A namespace for clear context
enum AnchorPreLiveToolbar {}

// MARK: Main components
extension AnchorPreLiveToolbar {
    
    final class CloseToolbar: UIView {
        private let stackView = UIStackView()
        private(set) var closeButton = KKBaseButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            return nil
        }
   
        private func configureUI() {
            configureStackView()
        }
        
        private func configureStackView() {
            stackView.spacing = 16
            stackView.alignment = .leading
            stackView.distribution = .equalCentering
            
            addSubview(stackView)
            stackView.anchors.edges.pin(axis: .vertical)
            stackView.anchors.edges.pin(insets: 12, axis: .horizontal)
            
            configureCloseButton()
            configureInvisibleView()
        }
        
        private func configureCloseButton() {
            closeButton.setImage(.iconCloseWhite, for: .normal)
            closeButton.clipsToBounds = true
            
            stackView.addArrangedSubview(closeButton)
            closeButton.anchors.height.equal(anchors.height)
            closeButton.anchors.width.equal(anchors.height)
        }
        
        private func configureInvisibleView() {
            let invisibleView = UIView()
            invisibleView.backgroundColor = .clear
            invisibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            stackView.addArrangedSubview(invisibleView)
        }
    }
    
    final class TopToolbarView: UIView {
        private let containerView = UIView()
        private let userImageView = UIImageView()
        
        private let rightContentStack = UIStackView()
        private(set) var roomTitleTextView = GrowingTextView()
        private(set) var editingButton = KKBaseButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            return nil
        }
        
        private func configureUI() {
            configureContainerView()
            configureUserImageView()
            configureRightContentStack()
        }
        
        private func configureContainerView() {
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            
            addSubview(containerView)
            containerView.anchors.edges.pin(axis: .vertical)
            containerView.anchors.edges.pin(insets: 40, axis: .horizontal)
        }
        
        private func configureUserImageView() {
            userImageView.contentMode = .scaleAspectFill
            userImageView.backgroundColor = .systemGray4
            userImageView.clipsToBounds = true
            
            containerView.addSubview(userImageView)
            userImageView.anchors.width.equal(48)
            userImageView.anchors.height.equal(48)
            userImageView.anchors.leading.pin(inset: 6)
            userImageView.anchors.centerY.align()
        }
        
        private func configureRightContentStack() {
            rightContentStack.axis = .horizontal
            rightContentStack.spacing = 10
            rightContentStack.alignment = .top
            
            containerView.addSubview(rightContentStack)
            rightContentStack.anchors.edges.pin(insets: 6, axis: .vertical)
            rightContentStack.anchors.leading.spacing(7, to: userImageView.anchors.trailing)
            rightContentStack.anchors.trailing.pin(inset: 6)
            
            configureRoomTitleTextfield()
            configureEditingButton()
        }
        
        private func configureRoomTitleTextfield() {
            roomTitleTextView.placeholder = "Judul live streaming"
            roomTitleTextView.maxLength = 100
            roomTitleTextView.placeholderColor = .softPeach
            roomTitleTextView.minHeight = 24
            roomTitleTextView.maxHeight = 48
            roomTitleTextView.font = .roboto(.medium, size: 14)
            roomTitleTextView.backgroundColor = .clear
            roomTitleTextView.textContainerInset = .zero
            roomTitleTextView.textContainer.lineFragmentPadding = 0
            roomTitleTextView.textColor = .white
            
            rightContentStack.addArrangedSubview(roomTitleTextView)
        }
        
        private func configureEditingButton() {
            editingButton.setImage(.iconPen, for: .normal)
            editingButton.backgroundColor = .clear
            editingButton.addTarget(self, action: #selector(editingButtonTapped), for: .touchUpInside)
            
            rightContentStack.addArrangedSubview(editingButton)
            editingButton.anchors.width.equal(13)
            editingButton.anchors.height.equal(13)
        }
        
        @objc private func editingButtonTapped() {
            roomTitleTextView.isEditable = true
            roomTitleTextView.becomeFirstResponder()
        }
    }
    
    final class BottomToolbarView: UIView {
        
        private(set) var startLiveButton = KKBaseButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configureUI()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            return nil
        }
  
        private func configureUI() {
            configureStartLiveButton()
        }
        
        private func configureStartLiveButton() {
            startLiveButton.setTitle("Mulai Live", for: .normal)
            startLiveButton.layer.cornerRadius = 20
            startLiveButton.setBackgroundColor(.watermelon, for: .normal)
            startLiveButton.setBackgroundColor(.sweetPink, for: .disabled)
            startLiveButton.isEnabled = false
            startLiveButton.font = .roboto(.bold, size: 14)
            startLiveButton.clipsToBounds = true
            
            addSubview(startLiveButton)
            startLiveButton.anchors.width.equal(anchors.width * 0.370)
            startLiveButton.anchors.height.equal(anchors.height)
            startLiveButton.anchors.center.align()
        }
    }
}

// MARK: API
extension AnchorPreLiveTopToolbar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
    }
   
    func setUserPhoto(_ source: String?) {
        userImageView.setImage(with: source, placeholder: .defaultProfileImage)
    }
}
