//
//  FeedArray.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - SelebArray
public struct FeedArray: Codable {
	public let code, message: String?
	public var data: FeedData?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

public struct FeedList: Codable {
    let feeds: [Feed]
}

// MARK: - FeedData
public struct FeedData: Codable {
	public var content: [Feed]?
//	public let pageable: Pageable?
	public let totalPages, totalElements: Int?
	public let last: Bool?
	public let sort: Sort?
	public let numberOfElements: Int?
	public let first: Bool?
	public let size, number: Int?
	public let empty: Bool?
    public let totalView: Int?
}

// MARK: - Feed
public struct Feed: Codable, Hashable, Equatable {
    
	public let id: String?
	public let typePost: String?
    public var post: Post?
	public let createAt: Int?
	public var likes, comments: Int?
	public let account: Profile?
	public var isRecomm, isReported, isLike, isFollow, isProductActiveExist: Bool?
	public let stories: [Stories]?
	public var feedPages: String?
    public var hashValue: Int {
         return id.hashValue
     }
    public let valueBased: String?
    public let typeBased: String?
    public let similarBy: String?
    public let mediaCategory: String?
    public var feedIndex: Int? = 0
    public var isReadyToShow: Bool? = false
    public var isTrending: Bool?
    
    public var cachedAt: Double?
    public var trendingAt: Int?
        
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
	public var statusLike: String {
		return isLike == false ? "unlike" : "like"
	}
    
    public static func == (lhs: Feed, rhs: Feed) -> Bool {
        return lhs.id == rhs.id
    }
    
	func mapToProfileContent() -> ContentProfilePost {
        return ContentProfilePost(id: id, typePost: typePost, postStory: nil, createAt: createAt, likes: likes, comments: comments, account: account, isRecomm: isRecomm, isReported: isReported, isLike: isLike, isFollow: isFollow, isProductActiveExist: isProductActiveExist, post: post, postProduct: nil)
	}
}

public struct FeedId: Codable, Hashable, Equatable {
    public let id: String?
    public var seenCount: Int
    
    init(id: String?, seenCount: Int = 1) {
        self.id = id
        self.seenCount = seenCount
    }
}

// MARK: - PostProduct
public struct PostStories: Codable {
	public let id: String?
	public let media: [Medias]?
	public let postProduct: [PostProduct]?

	enum CodingKeys: String, CodingKey {
		case id
		case media = "medias"
		case postProduct = "postProducts"
	}

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		media = try values.decodeIfPresent([Medias].self, forKey: .media)
		postProduct = try values.decodeIfPresent([PostProduct].self, forKey: .postProduct)
	}
}


// MARK: - Post
public struct Post: Codable {
	public let type: String?
	public var product: Product?
	public let price: Int?
	public let channel: Channel?
	public let id, name, postDescription: String?
	public var medias: [Medias]?
    public let hashtags: [Hashtag]?
    public let amountCollected: Double?
    public let targetAmount: Double?
    public var amountCollectedPercent: Float {
        return Float(Double(amountCollected ?? 0.0) / Double(targetAmount ?? 0.0))
    }
    public let donationCategory: DonationCategory?
    public let title: String?
    public let floatingLink, floatingLinkLabel, siteName, siteLogo: String?
    

	enum CodingKeys: String, CodingKey {
		case medias
		case type
		case id
		case price
		case product
		case name
		case channel
		case postDescription = "description"
        case hashtags
        case amountCollected
        case targetAmount
        case donationCategory
        case title
        case floatingLink
        case floatingLinkLabel
        case siteName
        case siteLogo
	}
    
    public struct Hashtag: Codable {
        public var value: String?
        public var total: Int?
    }
}

public struct DonationCategory: Codable {
    public let id: String?
    public let icon: String?
    public let name: String?
}

public struct Medias: Codable {
	public var id, type: String?
    public var url: String?
    public var isHlsReady: Bool?
    public var hlsUrl: String?
    public var thumbnail: Thumbnail?
    public var metadata: Metadata?
    public var vodFileId: String?
    public var vodUrl: String?
    
    public var playURL: String {
        get {
            if let videoURL = vodUrl, !videoURL.isEmpty {
                return videoURL
            }
            if let videoURL = url, !videoURL.isEmpty {
                return videoURL
            }
            return ""
        }
    }
}

public struct Media: Codable {
    public var id, type: String?
    public var url, thumbnail: String?
    public var metadata: Metadata?
}

public struct Metadata: Codable {
    public let width, height, size: String?
    public let duration: Double?
}

public struct Thumbnail: Codable {
    public let large, medium, small: String?
}

// MARK: - Pageable
public struct Pageable: Codable {
    public let sort: Sort?
    public let pageNumber, pageSize, offset: Int?
    public let paged, unpaged: Bool?
}

// MARK: - Sort
public struct Sort: Codable {
    public let sorted, unsorted, empty: Bool?
    
    enum CodingKeys: String, CodingKey {
        case empty = "empty"
        case sorted = "sorted"
        case unsorted = "unsorted"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        empty = try values.decodeIfPresent(Bool.self, forKey: .empty)
        sorted = try values.decodeIfPresent(Bool.self, forKey: .sorted)
        unsorted = try values.decodeIfPresent(Bool.self, forKey: .unsorted)
    }
}

// MARK: - Profile
public struct ProfileResult : Codable {

    public let code : String?
    public let data : Profile?
    public let message : String?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case data = "data"
        case message = "message"
    }
}

// MARK: - Profile
public class Profile : Codable {

    public let accountType : String?
    public let bio : String?
    public let email : String?
    public let id : String?
    public var isFollow : Bool?
    public let birthDate: String?
    public let note: String?
    public let isDisabled: Bool?
    public let isSeleb: Bool?
    public let isVerified : Bool?
    public let mobile : String?
    public let name : String?
    public let photo : String?
    public let username : String?
    public let isSeller: Bool?
    public let socialMedias: [SocialMedia]?
    public let referralCode : String?
    public let chatPrice: Int?
    

    enum CodingKeys: String, CodingKey {
        case accountType = "accountType"
        case bio = "bio"
        case email = "email"
        case id = "id"
        case isFollow = "isFollow"
        case birthDate = "birthDate"
        case note = "note"
        case isDisabled = "isDisabled"
        case isSeleb = "isSeleb"
        case isVerified = "isVerified"
        case mobile = "mobile"
        case name = "name"
        case photo = "photo"
        case username = "username"
        case isSeller = "isSeller"
        case socialMedias = "socialMedias"
        case referralCode = "referralCode"
        case chatPrice = "chatPrice"
    }
    
    init(accountType: String?, bio: String?, email: String?, id: String?, isFollow: Bool?, birthDate: String?, note: String?, isDisabled: Bool?, isSeleb: Bool?, isVerified: Bool?, mobile: String?, name: String?, photo: String?, username: String?, isSeller: Bool?, socialMedias: [SocialMedia]?, referralCode: String?, chatPrice: Int?) {
        self.accountType = accountType
        self.bio = bio
        self.email = email
        self.id = id
        self.isFollow = isFollow
        self.birthDate = birthDate
        self.note = note
        self.isDisabled = isDisabled
        self.isSeleb = isSeleb
        self.isVerified = isVerified
        self.mobile = mobile
        self.name = name
        self.photo = photo
        self.username = username
        self.isSeller = isSeller
        self.socialMedias = socialMedias
        self.referralCode = referralCode
        self.chatPrice = chatPrice
    }

}
public struct SocialMedia : Codable {
    
    public let socialMediaType : String?
    public let urlSocialMedia : String?
    
    enum CodingKeys: String, CodingKey {
        case socialMediaType = "socialMediaType"
        case urlSocialMedia = "urlSocialMedia"
    }
    
}

enum SocialMediaType: String {
    case instagram = "INSTAGRAM"
    case tiktok = "TIKTOK"
    case wikipedia = "WIKIPEDIA"
    case facebook = "FACEBOOK"
    case twitter = "TWITTER"
}

public struct EditProfile: Codable {
    public let name, bio, photo: String?
        public let socialMedias: [SocialMedia]?
}

extension Profile {
    static func emptyObject() -> Profile {
        return Profile(accountType: "", bio: "", email: "", id: "", isFollow: false, birthDate: "", note: "", isDisabled: false, isSeleb: false, isVerified: false, mobile: "", name: "", photo: "", username: "", isSeller: false, socialMedias: [], referralCode: "", chatPrice: 0)
    }
}

// MARK: - Stories
public struct Stories: Codable {
    public let id: String?
    public let media: [Medias]?
    public let postProducts: [Product]?
    public let createAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case media = "medias"
        case postProducts = "products"
        case createAt
    }
}

// MARK: - ContentProfilePost
public struct ContentProfilePost: Codable {
    public var id: String?
    public var typePost: String?
    public var postStory: PostStories?
    public var createAt, likes, comments: Int?
    public var account: Profile?
    public var isRecomm, isReported, isLike, isFollow, isProductActiveExist: Bool?
    public var post: Post?
    public var postProduct: PostProduct?
    
    enum CodingKeys: String, CodingKey {
        case account = "account"
        case comments = "comments"
        case createAt = "createAt"
        case id = "id"
        case isRecomm = "isRecomm"
        case isReported = "isReported"
        case isFollow = "isFollow"
        case isLike = "isLike"
        case isProductActiveExist = "isProductActiveExist"
        case likes = "likes"
        case post = "post"
        case postProduct = "postProduct"
        case postStory = "postStory"
        case typePost = "typePost"
    }
    func mapToFeed() -> Feed {
        return Feed(id: id, typePost: typePost, post: post, createAt: createAt, likes: likes, comments: comments, account: account, isRecomm: isRecomm, isReported: isReported, isLike: isLike, isFollow: isFollow, stories: nil, feedPages: nil, valueBased: nil, typeBased: nil, similarBy: nil, mediaCategory: nil)
    }
}

// MARK: - PostProduct
public struct PostProduct: Codable {
    public let id, name: String?
    public let price: Int?
    public let postProductDescription, color, size: String?
    public let measurement: Measurement?
    public let media: [Medias]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, price
        case postProductDescription = "description"
        case color, size, measurement
        case media = "medias"
    }
}

// MARK: - Measurement
public struct Measurement: Codable {
    public var weight, length, height, width: Double?
}

// MARK: - Product
public struct Product: Codable {
    public var accountId : String?
    public var postProductDescription : String?
    public var generalStatus : String?
    public var id : String?
    public var isDeleted : Bool?
    public var measurement : Measurement?
    public var medias : [Medias]?
    public var name : String?
    public var price : Double?
    public var sellerName : String?
    public var sold : Bool?
    public var productPages: String?
    public var reasonBanned: String?
    
    enum CodingKeys: String, CodingKey {
        case accountId = "accountId"
        case postProductDescription = "description"
        case generalStatus = "generalStatus"
        case id = "id"
        case isDeleted = "isDeleted"
        case measurement = "measurement"
        case medias = "medias"
        case name = "name"
        case price = "price"
        case sellerName = "sellerName"
        case sold = "sold"
        case reasonBanned = "reasonBanned"
    }
}

public struct Channel : Codable {
    
    public var descriptionField : String?
    public var id : String?
    public var name : String?
    public var photo : String?
    public var isFollow: Bool?
    public var code: String?
    
    enum CodingKeys: String, CodingKey {
        case descriptionField = "description"
        case id = "id"
        case name = "name"
        case photo = "photo"
        case isFollow = "isFollow"
        case code = "code"
    }
}

extension Channel: Hashable, Equatable {
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
}
