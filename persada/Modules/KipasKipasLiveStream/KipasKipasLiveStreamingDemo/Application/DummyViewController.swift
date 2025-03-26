import UIKit
import Combine
import KipasKipasShared
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import KipasKipasTRTC

protocol DummyDelegate: AnyObject {
    func didClickAnchor()
    func didClickLiveStreamingList()
    func didClickDailyRanking()
    func didClickGift()
}

final class DummyViewController: UIViewController, NavigationAppearance {
    
    private let stack = UIStackView()
    private let anchorButton = KKBaseButton()
    private let liveStreamingListButton = KKBaseButton()
    private let dailyRank = KKBaseButton()
    private let gift = KKBaseButton()
    // private lazy var giftPlayView = GiftPlayView()
    
    weak var delegate: DummyDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    //    override func loadView() {
    //        view = giftPlayView
    //    }
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        let rightButton = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendGift))
    //        navigationItem.rightBarButtonItem = rightButton
    //    }
    //
    //    @objc private func sendGift() {
    //        let list = Gifts.listGift[Int.random(in: 0...15)]
    //
    //        let messageData = createGiftMessage(
    //            .init(
    //                giftId: list.giftId,
    //                lottieUrl: list.lottieUrl,
    //                imageUrl: list.giftImageUrl,
    //                message: "Mengirim " + list.title,
    //                extInfo: .init(
    //                    value: .init(
    //                        userId: UUID().uuidString,
    //                        userName: "Beka",
    //                        avatarUrl: "https://ui-avatars.com/api/?name=\(randomString(length: 1))+\(randomString(length: 1))&background=random"
    //                    )
    //                )
    //            )
    //        )
    //
    //        giftPlayView.onReceiveMessage(messageData)
    //    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        view.backgroundColor = .white
        
        stack.axis = .vertical
        stack.spacing = 10
        view.addSubview(stack)
        stack.anchors.center.align()
        
        anchorButton.setTitle("Anchor", for: .normal)
        anchorButton.setTitleColor(.watermelon, for: .normal)
        stack.addArrangedSubview(anchorButton)
        
        liveStreamingListButton.setTitle("Live Streaming List", for: .normal)
        liveStreamingListButton.setTitleColor(.watermelon, for: .normal)
        stack.addArrangedSubview(liveStreamingListButton)
        
        dailyRank.setTitle("Daily Ranking", for: .normal)
        dailyRank.setTitleColor(.watermelon, for: .normal)
        stack.addArrangedSubview(dailyRank)
        
        gift.setTitle("Gift", for: .normal)
        gift.setTitleColor(.watermelon, for: .normal)
        stack.addArrangedSubview(gift)
        
        anchorButton.tapPublisher
            .sink { [weak self] in
                self?.delegate?.didClickAnchor()
            }
            .store(in: &cancellables)
        
        liveStreamingListButton.tapPublisher
            .sink { [weak self] in
                self?.delegate?.didClickLiveStreamingList()
            }
            .store(in: &cancellables)
        
        dailyRank.tapPublisher
            .sink { [weak self] in
                
                
                let info:[String : Any] = ["userId":"ff80808171c0e5a00171c3b86d7e0001",
                                        "photo":"https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/account/1645180937670.jpeg",
                                        "name":"er-qy-test",
                                        "isVerified":true]
                KKCache.common.save(dictionary: info, key: .roomInfoCache)
                
                self?.delegate?.didClickDailyRanking()
            }
            .store(in: &cancellables)
        
        gift.tapPublisher
            .sink { [weak self] in
                self?.delegate?.didClickGift()
            }
            .store(in: &cancellables)
    }
}

//func randomString(length: Int) -> String {
//  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//  return String((0..<length).map{ _ in letters.randomElement()! })
//}
