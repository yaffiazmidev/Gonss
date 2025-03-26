import UIKit
import KipasKipasShared

final class StorySendMessageView: UIView {
    
    private let stackContainer = UIStackView()
    private let stackEmojis = UIStackView()
    private let textField = KKBaseTextField()
    
    private let firstEmojiButton = KKBaseButton()
    private let secondEmojiButton = KKBaseButton()
    private let thirdEmojiButton = KKBaseButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UI
private extension StorySendMessageView {
    func configureUI() {
        clipsToBounds = true
        configureStackContainer()
        configureTextField()
        configureStackEmojis()
    }
    
    func configureStackContainer() {
        stackContainer.distribution = .fillEqually
        stackContainer.alignment = .center
        stackContainer.backgroundColor = .clear
        
        addSubview(stackContainer)
        stackContainer.anchors.edges.pin(insets: 12)
    }
    
    func configureTextField() {
        textField.placeholderText = "Kirim pesan..."
        textField.font = .roboto(.regular, size: 16)
        textField.placeholderColor = .ashGrey
        textField.placeholderLabel.font = .roboto(.regular, size: 16)
        textField.textColor = .ashGrey
        textField.isEnabled = false
        
        stackContainer.addArrangedSubview(textField)
    }
    
    func configureStackEmojis() {
        stackEmojis.spacing = 12
        stackEmojis.alignment = .center
        stackContainer.addArrangedSubview(stackEmojis)
        
        configureFirstEmojiButton()
        configureSecondEmojiButton()
        configureThirdEmojiButton()
    }
    
    private func configureFirstEmojiButton() {
        firstEmojiButton.backgroundColor = .clear
        firstEmojiButton.setTitle("😁")
        firstEmojiButton.font = .roboto(.regular, size: 28)
        
        stackEmojis.addArrangedSubview(firstEmojiButton)
    }
    
    private func configureSecondEmojiButton() {
        secondEmojiButton.backgroundColor = .clear
        secondEmojiButton.setTitle("😂")
        secondEmojiButton.font = .roboto(.regular, size: 28)
        
        stackEmojis.addArrangedSubview(secondEmojiButton)
    }
    
    private func configureThirdEmojiButton() {
        thirdEmojiButton.backgroundColor = .clear
        thirdEmojiButton.setTitle("🥰")
        thirdEmojiButton.font = .roboto(.regular, size: 28)
        
        stackEmojis.addArrangedSubview(thirdEmojiButton)
    }
}
