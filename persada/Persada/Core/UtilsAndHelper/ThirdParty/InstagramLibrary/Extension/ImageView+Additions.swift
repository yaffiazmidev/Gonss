import UIKit
import Kingfisher

enum ImageStyle: Int {
    case squared,rounded
}

typealias SetImageRequester = (IGResult<Bool,Error>) -> Void

extension UIImageView: IGImageRequestable {
    func setImage(url: String,
                  style: ImageStyle = .rounded,
                  completion: SetImageRequester? = nil, emptyImage: String = .get(.empty)) {
        image = nil

        //The following stmts are in SEQUENCE. before changing the order think twice :P
        isActivityEnabled = true
        layer.masksToBounds = false
        if style == .rounded {
            layer.cornerRadius = frame.height/2
            activityStyle = .white
        } else if style == .squared {
            layer.cornerRadius = 0
            activityStyle = .whiteLarge
        }
        clipsToBounds = true
        
        var urlValid = url
        if url.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = url + ossPerformance + OSSSizeImage.w576.rawValue
        }
        
        guard let finalURL = URL(string: urlValid) else {
            return
        }
        
        let retry = DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(1))
        let placeholderImage = UIImage(named: emptyImage)
        self.kf.indicatorType = .activity
        
        KF.url(finalURL)
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            .cacheMemoryOnly()
            .onSuccess { result in
                completion?(IGResult.success(true))
            }
            .onFailure { error in
                completion?(IGResult.failure(error))
            }
            .set(to: self)

    }
}
