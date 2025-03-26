import UIKit
import KipasKipasShared

public protocol ProfilePictureCropDelegate {
    func didCropped(media item: KKMediaItem)
}

public class ProfilePictureCropController: UIViewController {
    
    private let mainView: ProfilePictureCropView
    public var delegate: ProfilePictureCropDelegate?
    
    private let item: KKMediaItem
    
    public init(item: KKMediaItem) {
        mainView = ProfilePictureCropView()
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupOnTap()
    }
}

// MARK: - Helper
extension ProfilePictureCropController {
    func setupOnTap() {
        mainView.cancelButton.onTap {
            self.dismiss(animated: true)
        }
        
        mainView.saveButton.onTap {
            self.handleCrop()
        }
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        mainView.scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if mainView.scrollView.zoomScale == mainView.scrollView.minimumZoomScale {
            let location = gestureRecognizer.location(in: mainView.imageView)
            let rectToZoomTo = CGRect(x: location.x, y: location.y, width: 1, height: 1)
            mainView.scrollView.zoom(to: rectToZoomTo, animated: true)
        } else {
            mainView.scrollView.setZoomScale(mainView.scrollView.minimumZoomScale, animated: true)
        }
    }
    
    func setupView() {
        mainView.scrollView.delegate = self
        
        let imageSize = UIScreen.main.bounds.size.width - 40
        mainView.imageAreaWidthAnchor.constant = imageSize
        mainView.imageAreaHeightAnchor.constant = imageSize
        mainView.imageView.image = image(target: imageSize)
        mainView.imageView.contentMode = .scaleAspectFit
        mainView.layoutIfNeeded()
        
        
        let centerX = (mainView.scrollView.contentSize.width - mainView.scrollView.bounds.width) / 2
        let centerY = (mainView.scrollView.contentSize.height - mainView.scrollView.bounds.height) / 2
        mainView.scrollView.setContentOffset(CGPoint(x: centerX, y: centerY), animated: false)
    }
    
    private func image(target size: CGFloat) -> UIImage? {
        if let image = UIImage(data: item.data ?? Data()) {
            if image.size.height > image.size.width {
                return image.resizeImage(scale: size / image.size.width)
            } else {
                return image.resizeImage(scale: size / image.size.height)
            }
        }
        
        return nil
    }
    
    private func handleCrop() {
        if let image = mainView.imageView.crop(rect: mainView.scrollView.visibleRect(for: mainView.imageView)), let item = image.toMediaItem() {
            dismiss(animated: true) {
                self.delegate?.didCropped(media: item)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ProfilePictureCropController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainView.imageView
    }
}
