import UIKit
import Combine
import KipasKipasShared
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import KipasKipasNetworking

extension SceneDelegate {

    func makeDailyRankViewController(_ selectNavLeft:Bool) -> UIViewController {
        return DailyRankUIComposer.composeAudienceListUIWith(
            isAnchor:false,
            selectNavLeft:selectNavLeft,
            loader: makeDailyRankLoader,
            popularLiveLoader:makePopularLiveLoader,
            selection: { _ in },
            sendGiftAction: {  }
        )
    }
    
    func showDailyRankViewController(_ selectNavLeft:Bool,_ sendGiftAction: ()->Void) {
        let destination = makeDailyRankViewController(selectNavLeft)
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
