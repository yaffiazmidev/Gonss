import UIKit
import KipasKipasShared

protocol StoryPhotoTextEditorDelegate: AnyObject {
    func didEnterTextEditingMode()
    func didExitTextEditingMode(result textView: UITextView?)
}

final class StoryTextEditorViewController: UIViewController, NavigationAppearance {
    
    struct State {
        var lastTextViewTransform: CGAffineTransform = .identity
        var lastTextViewCenter: CGPoint = .zero
        var lastTextViewAlignment: NSTextAlignment = .center
    }
    
    private let backgroundView = UIView()
    private let stackMenu = UIStackView()
    
    private let alignmentButton = KKBaseButton()
    private let colorButton = KKBaseButton()
    
    private let colorPickerView = ColorPickerCollectionView()
    private var colorPickerBottomConstraint: NSLayoutConstraint! {
        didSet { colorPickerBottomConstraint.isActive = true }
    }
    
    private let fontButton = KKBaseButton()
    
    private(set) var state = State() {
        didSet { reconfigureTextView(with: state) }
    }
    
    weak var delegate: StoryPhotoTextEditorDelegate?
    
    private var keyboardHandler: KeyboardHandler?
    
    private var textView: UITextView!
    
    private let editingTextView: UITextView?
    
    init(editingTextView: UITextView?) {
        self.editingTextView = editingTextView
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(color: .clear, isTransparent: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureKeyboardObserver()
        
        addTextView()
        delegate?.didEnterTextEditingMode()
    }
    
    // MARK: Private
    private func addTextView() {
        let textViewFrame = CGRect(
            origin: .init(x: 16, y: view.center.y),
            size: .init(
                width: view.bounds.size.width - 32,
                height: 30
            ))
        
        textView = UITextView(frame: textViewFrame)
        textView.textAlignment = .center
        textView.font = .roboto(.regular, size: 25)
        textView.tintColor = .watermelon
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        
        
        // Set value to current textView if editingTextView not nil
        textView.textAlignment = editingTextView?.textAlignment ?? .center
        textView.textColor = editingTextView?.textColor ?? .white
        textView.text = editingTextView?.text
        
        state.lastTextViewAlignment = textView.textAlignment
        state.lastTextViewTransform = textView.transform
        state.lastTextViewCenter = textView.center
        
        textView.isSelectable = true
        textView.isEditable = true
        textView.delegate = self
        
        view.addSubview(textView)
        
        textViewDidChange(textView)
        textView.becomeFirstResponder()
    }
    
    private func reconfigureTextView(with state: State) {
        textView.textAlignment = state.lastTextViewAlignment
        
        switch state.lastTextViewAlignment {
        case .left:
            alignmentButton.setImage(UIImage.Story.iconAlignmentLeft)
        case .center:
            alignmentButton.setImage(UIImage.Story.iconAlignmentCenter)
        case .right:
            alignmentButton.setImage(UIImage.Story.iconAlignmentRight)
        default:
            break
        }
    }
    
    private func cleanUp() {
        navigationController?.removeFromParentView()
        keyboardHandler?.unsubscribe()
        keyboardHandler = nil
    }
    
    @objc private func didTapDone() {
        view.endEditing(true)
        cleanUp()
    }
    
    @objc private func didChangeAlignment() {
        switch state.lastTextViewAlignment {
        case .left:
            state.lastTextViewAlignment = .right
        case .center:
            state.lastTextViewAlignment = .left
        case .right:
            state.lastTextViewAlignment = .center
        default:
            break
        }
    }
}

// MARK: UITextViewDelegate
extension StoryTextEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            textView.calculateSize()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                textView.transform = CGAffineTransform.identity
                textView.center = CGPoint(
                    x: self.view.bounds.width / 2,
                    y: self.view.bounds.height / 3
                )
            }, completion: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let lastEditingTransform = editingTextView?.transform
        let lastEditingCenter = editingTextView?.center
        
        UIView.animate(withDuration: 0.3) {
            textView.transform = self.state.lastTextViewTransform
            textView.center = self.state.lastTextViewCenter
            
            if let editingTextView = self.editingTextView {
                textView.isHidden = true
                
                editingTextView.transform = textView.transform
                editingTextView.center = textView.center
                editingTextView.text = textView.text
                editingTextView.textColor = textView.textColor
                editingTextView.textAlignment = textView.textAlignment
                
                self.delegate?.didExitTextEditingMode(result: editingTextView)
                
            } else {
                if textView.text.isEmpty == true {
                    self.delegate?.didExitTextEditingMode(result: nil)
                } else {
                    self.delegate?.didExitTextEditingMode(result: textView)
                }
            }
        }
        
        if let editingTextView = editingTextView {
            editingTextView.transform = lastEditingTransform ?? .identity
            editingTextView.center = lastEditingCenter ?? .zero
            editingTextView.calculateSize(isUsingGesture: true)
        }
        
        self.delegate = nil
    }
}

// MARK: ColorPickerDelegate
extension StoryTextEditorViewController: ColorPickerDelegate {
    func didSelectColor(_ color: UIColor?) {
        textView.textColor = color
    }
}

// MARK: Keyboard Handling
private extension StoryTextEditorViewController {
    func configureKeyboardObserver() {
        keyboardHandler = KeyboardHandler(with: { [weak self] state in
            self?.handleKeyboard(state)
        })
    }
    
    func handleKeyboard(_ state: KeyboardState) {
        switch state.state {
        case .willShow:
            UIView.animate(withDuration: 0.3) {
                self.moveViewAboveKeyboard(height: state.height)
                self.view.layoutIfNeeded()
            }
        case .willHide:
            UIView.animate(withDuration: 0.3) {
                self.resetViewPosition()
            }
        default: break
        }
    }
    
    func moveViewAboveKeyboard(height: CGFloat) {
        let viewHeight = colorPickerView.frame.size.height
        let keyboardY = height - (viewHeight * 2)
        
        colorPickerBottomConstraint.constant = -keyboardY
    }
    
    func resetViewPosition() {
        if colorPickerBottomConstraint.constant < 0 {
            colorPickerBottomConstraint.constant = 0
        }
    }
}

// MARK: UI
private extension StoryTextEditorViewController {
    func configureUI() {
        view.backgroundColor = .clear
        
        configureBackgroundView()
        configureStackMenu()
        configureDoneButton()
        configureColorPickerView()
    }
    
    func configureBackgroundView() {
        backgroundView.backgroundColor = UIColor.night
        backgroundView.alpha = 0.5
        
        view.addSubview(backgroundView)
        backgroundView.anchors.edges.pin()
    }
    
    func configureStackMenu() {
        stackMenu.alignment = .center
        stackMenu.spacing = 10
        
        navigationItem.titleView = stackMenu
        
        configureAlignmentButton()
        configureColorButton()
        configureFontButton()
    }
    
    func configureAlignmentButton() {
        alignmentButton.backgroundColor = .clear
        alignmentButton.setBackgroundImage(UIImage.Story.iconAlignmentCenter, for: .normal)
        alignmentButton.tintColor = .white
        alignmentButton.addTarget(self, action: #selector(didChangeAlignment), for: .touchUpInside)
        configureCommonButtonStyle(alignmentButton)
    }
    
    func configureColorButton() {
        colorButton.backgroundColor = .clear
        colorButton.setBackgroundImage(UIImage.Story.iconColorPicker, for: .normal)
        configureCommonButtonStyle(colorButton)
    }
    
    func configureFontButton() {
        fontButton.backgroundColor = .clear
        fontButton.setBackgroundImage(UIImage.Story.iconFont, for: .normal)
        fontButton.isHidden = true
        configureCommonButtonStyle(fontButton)
    }
    
    func configureCommonButtonStyle(_ button: UIButton) {
        stackMenu.addArrangedSubview(button)
        button.anchors.width.equal(40)
        button.anchors.height.equal(40)
    }
    
    func configureDoneButton() {
        let doneButton = UIBarButtonItem(
            title: "Selesai",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )
        doneButton.tintColor = .white
        navigationItem.setRightBarButton(doneButton, animated: false)
    }
    
    func configureColorPickerView() {
        colorPickerView.colorDelegate = self
        view.addSubview(colorPickerView)
        
        colorPickerBottomConstraint = colorPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        colorPickerView.anchors.edges.pin(axis: .horizontal)
        colorPickerView.anchors.height.equal(44)
    }
}
