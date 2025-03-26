import Foundation

public enum StoryPerspective {
    case me
    case friends
}

public struct StorySectionViewModel: Equatable {
    public let feedId: String
    public let typePost: String
    public var stories: [StoryItemViewModel]
    
    public init(
        feedId: String,
        typePost: String,
        stories: [StoryItemViewModel]
    ) {
        self.feedId = feedId
        self.typePost = typePost
        self.stories = stories
    }
    
    public static func ==(lhs: StorySectionViewModel, rhs: StorySectionViewModel) -> Bool {
        return lhs.feedId == rhs.feedId && lhs.stories == rhs.stories
    }
}

public extension StoryFeed {
    func toViewModel(_ perspective: StoryPerspective) -> StorySectionViewModel? {
        let section = StorySectionViewModel(
            feedId: id ?? "",
            typePost: typePost ?? "",
            stories: stories?.compactMap { story in
                let media = story.medias.first
                
                return StoryItemViewModel(
                    id: story.id,
                    feedId: story.feedId,
                    repostId: story.feedIdRepost ?? "",
                    repostOwnerUsername: story.usernameRepost ?? "",
                    firstViewerAccountId: story.firstSeenAccountId ?? "",
                    firstViewerPhoto: story.firstSeenPhoto ?? "",
                    secondViewerAccountId: story.secondSeenAccountId ?? "",
                    secondViewerPhoto: story.secondSeenPhoto ?? "",
                    totalView: story.totalView,
                    type: StoryItemType(rawValue: story.storyType ?? "") ?? .post,
                    media: StoryItemMediaViewModel(
                        id: media?.id ?? "",
                        type: .init(rawValue: media?.type ?? "") ?? .image,
                        url: media?.url ?? "", 
                        vodURL: media?.vodUrl,
                        thumbnail: media?.thumbnail.large ?? "",
                        metadata: .init(duration: media?.metadata.duration ?? 0)
                    ),
                    createAt: story.createAt,
                    isViewed: story.isHasView,
                    isLiked: story.isLike == true,
                    perspective: perspective,
                    account: .init(
                        id: account?.id ?? "",
                        username: account?.username ?? "",
                        name: account?.name ?? "",
                        photo: account?.photo ?? "",
                        isVerified: account?.isVerified == true
                    )
                )
            } ?? []
        )
        return section.stories.isEmpty ? nil : section
    }
}

public extension Array where Element == StoryFeed {
    func toViewModels(_ perspective: StoryPerspective) -> [StorySectionViewModel] {
        return compactMap { $0.toViewModel(perspective) }
    }
}

