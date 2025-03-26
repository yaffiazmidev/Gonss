import KipasKipasStory

 extension StoryViewer {
    static var mocks: [StoryViewer] {
        return (1...25).map { index in
            return StoryViewer(
                id: "\(index)",
                username: "User \(Int.random(in: 1...1000))",
                name: "User \(Int.random(in: 1...1000))",
                photo: "https://api.dicebear.com/9.x/initials/jpeg?seed=User+\("ABCDEFGHIJKLMNOPQ".randomElement()!)",
                isLike: Bool.random(),
                isVerified: Bool.random(),
                isFollow: Bool.random(),
                isFollowed: Bool.random()
            )
        }
//        [
//            StoryViewer(
//                id: "1",
//                username: "beka",
//                name: "Bayu Kurniawan",
//                photo: "https://api.dicebear.com/9.x/initials/jpeg?seed=Beka",
//                isLike: true,
//                isVerified: true,
//                isFollow: false,
//                isFollowed: false
//            ),
//            StoryViewer(
//                id: "2",
//                username: "ryanreynolds",
//                name: "Ryan Reynolds",
//                photo: "https://api.dicebear.com/9.x/initials/jpeg?seed=RR",
//                isLike: true,
//                isVerified: true,
//                isFollow: true,
//                isFollowed: false
//            ),
//            StoryViewer(
//                id: "3",
//                username: "dominic",
//                name: "Dominica",
//                photo: "https://api.dicebear.com/9.x/initials/jpeg?seed=DO",
//                isLike: false,
//                isVerified: false,
//                isFollow: false,
//                isFollowed: true
//            ),
//            StoryViewer(
//                id: "4",
//                username: "cherry",
//                name: "Cherry",
//                photo: "https://api.dicebear.com/9.x/initials/jpeg?seed=CH",
//                isLike: false,
//                isVerified: false,
//                isFollow: true,
//                isFollowed: true
//            )
//        ]
    }
}

extension StoryViewersResponse {
    static func mock(isEmpty: Bool = false) -> StoryViewersResponse {
        return .init(
            code: "1000",
            message: "General Success",
            data: .init(
                content: isEmpty ? [] : StoryViewer.mocks,
                pageable: .init(
                    offsetPage: 0,
                    sort: .init(
                        sorted: true,
                        unsorted: true,
                        empty: true
                    ),
                    startId: nil,
                    nocache: nil,
                    pageNumber: 0,
                    pageSize: 10,
                    offset: 0,
                    paged: true,
                    unpaged: false
                ),
                totalPages: 2,
                totalElements: 20,
                last: true,
                number: 0,
                size: 10,
                numberOfElements: 20,
                sort: .init(
                    sorted: true,
                    unsorted: false,
                    empty: false
                ),
                first: true,
                empty: false
            )
        )
    }
}

