import UIKit
import KipasKipasShared
import KipasKipasCamera
import KipasKipasImage

public final class StoryPhotoEditorViewController: StoryEditorViewController {
    
    private let imageView = UIImageView()
    
    public var image: UIImage? {
        didSet {
            guard let image = image else { return }
            setImage(image)
        }
    }
    
    public var photoURL: URL? {
        didSet {
            guard let url = photoURL else { return }
            fetchImage(
                with: .init(url: url, size: .w_300),
                into: imageView
            )
        }
    }
    
    // MARK: Lifecycles
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
    }
    
    private func setImage(_ image: UIImage) {
        imageView.image = image
        fillEmptyImageAreaIfNeeded(image)
        adjustImageContentMode(image)
    }
    
    public override func saveMedia() {
        let image = outputView.toImage()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage), nil)
    }
    
    public override func exportMedia(with completion: @escaping (KKMediaItem) -> Void) {
        if let imageData = outputView.toImage().jpegData(compressionQuality: 1.0) {
            let url = imageData.writeToTemporaryStoryImagePath()
            
            completion(.init(
                data: imageData,
                path: url.absoluteString,
                type: .photo,
                postType: .story
            ))
        }
    }
    
    @objc private func saveImage(
        _ image: UIImage,
        withPotentialError error: NSError?,
        contextInfo: UnsafeRawPointer
    ) {
        if error == nil {
            image.jpegData(compressionQuality: 1.0)?.writeToTemporaryStoryImagePath()
            showToast(with: "Berhasil menyimpan ke galeri", verticalSpace: 30)
        }
    }
}

// MARK: Sizing & Content Mode
private extension StoryPhotoEditorViewController {
    func adjustImageContentMode(_ image: UIImage) {
        let fittedSize = calculateFittedImageSize(image.size)
        let imageWidth = fittedSize.width
        let imageHeight = fittedSize.height
        
        let viewSize = view.bounds.size
        let shouldFill = imageWidth >= viewSize.width && imageHeight >= viewSize.height * 0.7
        
        let adjustedContentMode: UIView.ContentMode = shouldFill ? .scaleAspectFill : .scaleAspectFit
        
        imageView.contentMode = adjustedContentMode
        overlayView.contentMode = adjustedContentMode
    }
    
    func calculateFittedImageSize(_ imageSize: CGSize) -> CGSize {
        let viewSize = view.bounds.size
        
        let widthRatio = viewSize.width / imageSize.width
        let heightRatio = viewSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        let fittedWidth = (imageSize.width * scale).rounded()
        let fittedHeight = (imageSize.height * scale).rounded()
        
        return CGSize(width: fittedWidth, height: fittedHeight)
    }
    
    func fillEmptyImageAreaIfNeeded(_ image: UIImage?) {
        let averageColors = image?.averageColors()
        
        if let topColor = averageColors?.top,
           let bottomColor = averageColors?.bottom {
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.frame = view.bounds
            
            mediaView.layer.insertSublayer(gradientLayer, at: 0)
            
            mediaView.layoutSubviewsCallback = { [weak self] in
                gradientLayer.frame = self?.view.bounds ?? .zero
            }
        } else {
            mediaView.backgroundColor = image?.averageColor(rect: view.bounds)
        }
    }
}

// MARK: UI
private extension StoryPhotoEditorViewController {
    func configureImageView() {
        imageView.backgroundColor = .clear
        
        mediaView.addSubview(imageView)
        imageView.anchors.edges.pin()
    }
}
