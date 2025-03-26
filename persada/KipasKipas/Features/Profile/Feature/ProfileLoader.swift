//
//  ProfileLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import FeedCleeps


// MARK: Kalo ada waktu, tolong dirapiin ya 
protocol ProfileLoader {
    func data(request: ProfileLoaderDataRequest, completion: @escaping (Swift.Result<RemoteUserProfileData, Error>) -> Void)
    func mutual(request: ProfileLoaderMutualRequest, completion: @escaping (Swift.Result<RemoteAcountMutualData, Error>) -> Void)
    func post(request: PagedFeedVideoLoaderRequest, completion: @escaping (Swift.Result<RemoteFeedItemData, Error>) -> Void)
    func updatePicture(request: ProfileLoaderUpdatePictureRequest, completion: @escaping (Swift.Result<String, Error>) -> Void)
}
