import UIKit
import Combine
import KipasKipasShared
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import KipasKipasNetworking

extension AppDelegate {
    
    private func makeDailyRankViewController(isAnchor: Bool,selectNavLeft:Bool,sendGiftAction:@escaping()->Void) -> UIViewController {
        return DailyRankUIComposer.composeAudienceListUIWith(
            isAnchor:isAnchor,
            selectNavLeft:selectNavLeft,
            loader: makeDailyRankLoader,
            popularLiveLoader:makePopularLiveLoader,
            selection: isAnchor ? { _ in } : navigateToProfileViewController,
            sendGiftAction: (isAnchor ? {} : sendGiftAction)
        )
    }
    
    func showDailyRankViewController(isAnchor: Bool,selectNavLeft:Bool,sendGiftAction:@escaping()->Void) {
        let destination = makeDailyRankViewController(isAnchor: isAnchor,selectNavLeft: selectNavLeft,sendGiftAction: sendGiftAction)
        let navigation = PanNavigationViewController(rootViewController: destination)
        window?.topViewController?.presentPanModal(navigation)
    }
    
    private func makeDailyRankLoader() -> AnyPublisher<LiveDailyRank, Error> {
        let request = LiveStreamEndpoint.dailyRank.url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<LiveDailyRank>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makePopularLiveLoader() -> AnyPublisher<LiveDailyRank, Error> {
        let request = LiveStreamEndpoint.popularLive.url(baseURL: baseURL)
        return authenticatedHTTPClient
            .getPublisher(request: request)
            .tryMap(Mapper<LiveDailyRank>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}
