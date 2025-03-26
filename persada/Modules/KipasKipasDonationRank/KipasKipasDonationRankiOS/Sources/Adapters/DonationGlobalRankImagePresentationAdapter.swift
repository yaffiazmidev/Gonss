import Foundation
import KipasKipasDonationRank
import Kingfisher
import UIKit

final class DonationGlobalRankImagePresentationAdapter: DonationGlobalRankCellControllerDelegate {
    
    private var prefetcher: ImagePrefetcher?
    
    private let item: [DonationGlobalRankItem]
    
    init(item: [DonationGlobalRankItem]) {
        self.item = item
        configureKFCache()
    }
    
    private func configureKFCache() {
        let cache = KingfisherManager.shared.cache
        cache.memoryStorage.config.totalCostLimit = 10 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
        cache.memoryStorage.config.expiration = .seconds(120)
        cache.memoryStorage.config.cleanInterval = 30
    }
    
    func prefetchImages(completion: @escaping ([URL]) -> Void) {
        let profileURLs = item.compactMap { URL(string: $0.profileImageURL + "?x-oss-process=image/format,jpg/interlace,1/resize,w_100") }
        let badgeURLs = item.compactMap { URL(string: $0.badgeURL + "?x-oss-process=image/format,png/resize,w_200") }
        let urls = profileURLs + badgeURLs
        
        prefetcher = ImagePrefetcher(urls: urls) {
            skippedResources, failedResources, completedResources in
        }
        prefetcher?.maxConcurrentDownloads = urls.count
        
        prefetcher?.start()
        
        completion(urls)
    }

    func didCancelRequestLoadImage() {
        prefetcher?.stop()
        prefetcher = nil
    }
}
