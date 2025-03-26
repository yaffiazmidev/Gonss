//
//  DonationCellViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 30/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct DonationCellViewModel {
    let imagePostUrl: String?
    let imageUserUrl: String?
    let videoUserUrl: String?
    let likes: Int?
    let date: Int?
    let comments: Int?
    let title: String?
    let name: String?
    let id: String?
    
    init?(value: Donation?) {
        
        guard let id: String = value?.id,
            let imageUserUrl: String = value?.account?.photo,
            let name: String = value?.account?.name,
            let likes: Int = value?.likes,
            let comments: Int = value?.comments,
            let date: Int = value?.createAt,
            let title: String = value?.postDonation?.title
            else {
                return nil
        }
        
        if value?.postDonation?.media?.first?.type == "image" {
            self.videoUserUrl = ""
        } else {
            self.videoUserUrl = value?.postDonation?.media?.first?.url
        }
        
        if value?.postDonation?.media?.first?.type == "video" {
            self.imagePostUrl = ""
        } else {
            self.imagePostUrl = value?.postDonation?.media?.first?.url
        }
        
        self.title = title
        self.id = id
        self.likes = likes
        self.comments = comments
        self.imageUserUrl = imageUserUrl
        self.name = name
        self.date = date
        
    }
}

