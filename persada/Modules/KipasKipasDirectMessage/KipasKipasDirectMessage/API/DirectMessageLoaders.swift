import Combine
import KipasKipasNetworking

public typealias DirectMessageRegisterLoader = AnyPublisher<EmptyData, Error>
public typealias ListFollowingLoader = AnyPublisher<Root<DirectMessageFollowing>, Error>
public typealias SearchAccountByUsernameLoader = AnyPublisher<Root<[RemoteSearchUserData]>, Error>
public typealias PaidChatPriceLoader = AnyPublisher<Root<PaidChatPrice>, Error>
public typealias PaidSessionBalanceLoader = AnyPublisher<Root<PaidSessionBalance>, Error>
public typealias ChatSessionLoader = AnyPublisher<ChatSession, DirectMessageError>
public typealias SendChatLoader = AnyPublisher<Root<ChatSession>, DirectMessageError>
public typealias ConfirmationSetDiamondLoader = AnyPublisher<Root<RemoteSetDiamondData>, DirectMessageError>
public typealias OneSignalChatNotificationLoader = AnyPublisher<OneSignalChatNotification, Error>
public typealias ChatProfileLoader = AnyPublisher<Root<ChatProfile>, DirectMessageError>
public typealias AllowCallLoader = AnyPublisher<Root<AllowCall>, Error>
