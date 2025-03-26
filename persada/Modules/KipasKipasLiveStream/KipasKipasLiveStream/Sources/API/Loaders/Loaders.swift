import Foundation
import Combine
import KipasKipasNetworking

public typealias DailyRankLoader = AnyPublisher<LiveDailyRank, Error>

public typealias LiveCreateLoader = AnyPublisher<Root<LiveStreamCreation>, Error>

public typealias LiveValidationLoader = AnyPublisher<Root<LiveStreamValidation>, LiveStreamEndpoint.ValidationError>

public typealias ListAudienceLoader = AnyPublisher<Root<[LiveStreamAudience]>, Error>

public typealias LiveProfileLoader = AnyPublisher<Root<LiveUserProfile>, Error>

public typealias ListLiveRoomLoader = AnyPublisher<Root<LiveRoomActive>, Error>

public typealias FollowLoader = AnyPublisher<EmptyData, Error>

public typealias ListGiftLoader = AnyPublisher<Root<[LiveGift]>, Error>

public typealias LiveCoinBalanceLoader = AnyPublisher<Root<LiveCoinBalance>, Error>

public typealias LiveTopSeatLoader = AnyPublisher<Root<[LiveTopSeat]>, Error>

public typealias LiveSummaryLoader = AnyPublisher<Root<LiveStreamSummary>, Error>
