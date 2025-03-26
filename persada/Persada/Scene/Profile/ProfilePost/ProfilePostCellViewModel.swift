//
//  ProfilePostCellViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 17/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct ProfilePostCellViewModel {
    
    var imagePostUrl: String?
    let imageUserUrl: String?
    var videoUserUrl: String?
    let likes: Int?
    let date: Int?
    let comments: Int?
    let name: String?
    let id: String?
    let isFollow: Bool?
    let title: String? 
    
    init?(value: ContentProfilePost?) {
        
        guard let id = value?.id,
            let imageUserUrl = value?.account?.photo,
            let date = value?.createAt,
            let isFollow = value?.isFollow,
            let name = value?.account?.username else {
            return nil
        }
		
		if value?.likes == nil {
			self.likes = 0
		} else {
			self.likes = value?.likes
		}
		
		if value?.comments == nil {
			self.comments = 0
		} else {
			self.comments = value?.comments
		}
        
        if value?.typePost == "story" {

            self.title = value?.postStory?.postProduct?.first?.postProductDescription

            if value?.postStory?.postProduct?.first?.media?.first?.type == "image" {
                self.imagePostUrl = value?.postStory?.postProduct?.first?.media?.first?.url
                self.videoUserUrl = ""
            } else {
                self.videoUserUrl = value?.postStory?.postProduct?.first?.media?.first?.hlsUrl
                self.imagePostUrl = ""
            }
        } else if (value?.typePost == "seleb") || value?.typePost == "social" {
            
            if value?.post?.postDescription == nil {
                self.title = ""
            } else {
                self.title = value?.post?.postDescription ?? ""
            }
            
            if value?.post?.medias?.first?.type == "image" {
                self.imagePostUrl = value?.post?.medias?.first?.url
                self.videoUserUrl = ""
            } else {
                self.videoUserUrl = value?.post?.medias?.first?.hlsUrl
                self.imagePostUrl = ""
            }
        } else {
            
            if value?.postProduct?.name == nil {
                self.title = ""
            } else {
                self.title = value?.postProduct?.name ?? ""
            }
            
            if value?.postProduct?.media?.first?.type == "image" {
                self.imagePostUrl = value?.postProduct?.media?.first?.url
                self.videoUserUrl = ""
            } else {
                self.videoUserUrl = value?.postProduct?.media?.first?.hlsUrl
                self.imagePostUrl = ""
            }
        }

        self.isFollow = isFollow
        self.date = date
        self.id = id
        self.imageUserUrl = imageUserUrl
        self.name = name
    }
}
