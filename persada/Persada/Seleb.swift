//
//  SelebArray.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct SelebArray : Codable {
    
    let data : [Datum]?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }

}

struct Datum : Codable {
    
    let descriptionField : String?
    let expired : Int?
    let expiredAt : Int?
    let follow : Bool?
    let id : String?
    let owner : Owner?
    let post : Post?
    let price : Int?
    let title : String?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case descriptionField = "description"
        case expired = "expired"
        case expiredAt = "expiredAt"
        case follow = "follow"
        case id = "id"
        case owner = "owner"
        case post = "post"
        case price = "price"
        case title = "title"
        case type = "type"
    }
    
    
}

struct Post : Codable {
    
    let comments : Int?
    let date : Int?
    let id : String?
    let likes : Int?
    let media : [Media]?
    
    enum CodingKeys: String, CodingKey {
        case comments = "comments"
        case date = "date"
        case id = "id"
        case likes = "likes"
        case media = "media"
    }
    
    
}

struct Media : Codable {
    
    let id : String?
    let thumbnail : String?
    let video : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case thumbnail = "thumbnail"
        case video = "video"
    }
    
}

struct Owner : Codable {
    
    let follower : Int?
    let following : Int?
    let id : String?
    let name : String?
    let photo : String?
    let username : String?
    let verified : Bool?
    
    enum CodingKeys: String, CodingKey {
        case follower = "follower"
        case following = "following"
        case id = "id"
        case name = "name"
        case photo = "photo"
        case username = "username"
        case verified = "verified"
    }
}


