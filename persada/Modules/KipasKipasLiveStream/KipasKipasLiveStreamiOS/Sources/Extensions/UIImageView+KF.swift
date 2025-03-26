import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with source: String?, placeholder: UIImage? = nil) {
        kf.indicatorType = .activity
        kf.setImage(with: URL(string: source ?? ""), placeholder: placeholder)
    }
    
    func cancel() {
        kf.cancelDownloadTask()
    }
}
