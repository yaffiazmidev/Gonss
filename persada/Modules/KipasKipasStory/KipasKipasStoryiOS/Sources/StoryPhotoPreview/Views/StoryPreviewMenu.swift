import UIKit
import KipasKipasShared
import Combine

protocol StoryPreviewMenuDelegate: AnyObject {
    func didTapText()
    func didTapSave()
}

final class StoryPreviewMenu: UIView {
    
    private let stacker = Stacker()
    private let textButton = KKBaseButton()
    private let saveButton = KKBaseButton()
    
    weak var delegate: StoryPreviewMenuDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        observe()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func observe() {
        textButton
            .tapPublisher
            .sink { [weak self] in
                self?.delegate?.didTapText()
            }
            .store(in: &cancellables)
        
        saveButton
            .tapPublisher
            .sink { [weak self] in
                self?.delegate?.didTapSave()
            }
            .store(in: &cancellables)
    }
}

// MARK: UI
private extension StoryPreviewMenu {
    func configureUI(){
        configureStacker()
        configureTextButton()
        configureSaveButton()
    }
    
    func configureStacker() {
        stacker.isScrollEnabled = false
        stacker.alignment = .top
        stacker.spacingBetween = 8
        
        addSubview(stacker)
        stacker.anchors.edges.pin()
    }
    
    func configureTextButton() {
        configureCommonButtonStyle(textButton)
        textButton.setTitle("Aa")
        textButton.setTitleColor(.white, for: .normal)
        
        stacker.addArrangedSubViews(textButton)
        textButton.anchors.height.equal(40)
    }
    
    func configureSaveButton() {
        configureCommonButtonStyle(saveButton)
        saveButton.setImage(UIImage.Story.iconSave)
        
        stacker.addArrangedSubViews(saveButton)
        saveButton.anchors.height.equal(40)
    }
    
    func configureCommonButtonStyle(_ button: KKBaseButton) {
        button.tintColor = .white
        button.backgroundColor = UIColor.night.withAlphaComponent(0.2)
        button.clipsToBounds = true
        button.layer.cornerRadius = 40 / 2
        button.font = .roboto(.bold, size: 18)
    }
}
