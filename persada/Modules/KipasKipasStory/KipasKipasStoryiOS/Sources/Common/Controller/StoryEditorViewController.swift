import UIKit
import KipasKipasShared

public class StoryEditorViewController: UIViewController, StoryEditor {
    
    public weak var delegate: StoryEditorDelegate?

    var imageViewToPan: UIImageView?
    var lastPanPoint: CGPoint?
    
    /// Hold the original image and the drawing/text.
    private(set) var outputView = UIView()
    /// Hold the original media
    private(set) var mediaView = UIView()
    /// Hold the drawings/text
    private(set) var overlayView = UIView()
    
    let deleteButton = KKBaseButton()

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    public func switchToTextEditingMode(editingTextView textView: UITextView?) {
        let controller = StoryTextEditorViewController(editingTextView: textView)
        controller.delegate = self
        
        let navigation = UINavigationController(rootViewController: controller)
        add(navigation)
    }
    
    public func saveMedia() {
        fatalError("Need to override")
    }
    
    public func exportMedia(with completion: @escaping (KKMediaItem) -> Void) {
        fatalError("Need to override")
    }
}

// MARK: StoryPhotoTextEditorDelegate
extension StoryEditorViewController: StoryPhotoTextEditorDelegate {
    func didEnterTextEditingMode() {
        delegate?.didEnterEditingMode()
    }
    
    func didExitTextEditingMode(result textView: UITextView?) {
        if let textView = textView {
            textView.isEditable = false
            textView.isSelectable = false
            textView.center.y = overlayView.center.y
            
            overlayView.addSubview(textView)
            addGestures(for: textView)
        }
        
        delegate?.didExitEditingMode()
    }
}


// MARK: UI
private extension StoryEditorViewController {
    func configureUI() {
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        configureCanvasView()
        configureMediaView()
        configureCanvasImageView()
        configureDeleteButton()
    }
    
    func configureCanvasView() {
        outputView.backgroundColor = .clear
        
        view.addSubview(outputView)
        outputView.anchors.edges.pin()
    }
    
    func configureMediaView() {
        mediaView.backgroundColor = .clear
        
        outputView.addSubview(mediaView)
        mediaView.anchors.edges.pin()
    }
    
    func configureCanvasImageView() {
        overlayView.backgroundColor = .clear
        overlayView.isUserInteractionEnabled = true
        
        outputView.addSubview(overlayView)
        overlayView.anchors.edges.pin()
    }
    
    func configureDeleteButton() {
        deleteButton.isHidden = true
        deleteButton.backgroundColor = .clear
        deleteButton.setImage(UIImage.Story.iconTrashWhite)
        deleteButton.layer.cornerRadius = 50 / 2
        
        view.addSubview(deleteButton)
        deleteButton.anchors.centerX.align()
        deleteButton.anchors.bottom.equal(view.anchors.bottom, constant: -16)
        deleteButton.anchors.width.equal(50)
        deleteButton.anchors.height.equal(50)
    }
}

