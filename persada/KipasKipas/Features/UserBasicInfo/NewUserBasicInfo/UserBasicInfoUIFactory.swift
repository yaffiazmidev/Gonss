//
//  UserBasicInfoUIFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class UserBasicInfoUIFactory {
    
    static func create(
        inputUser: InputUserParams,
        onSuccessCreateNewUser: @escaping (String) -> Void
    ) -> UserBasicInfoViewController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let uploadURL = URL(string: APIConstants.uploadURL)!
        
        let emailValidator = RemoteEmailValidator(url: baseURL, client: HTTPClientFactory.makeHTTPClient())
        let usernameValidator = RemoteUsernameValidator(url: baseURL, client: HTTPClientFactory.makeHTTPClient())
        let uploader = RemoteUserPhotoUploader(url: uploadURL, client: HTTPClientFactory.makeHTTPClient())
        
        let creater = RemoteCreateUser(url: baseURL, client: HTTPClientFactory.makeHTTPClient())
        let cacheUser = CacheUserDecorator(decoratee: creater, store: KeychainUserStore())
        let registerChat = RemoteCreateUserChatDecorator(decoratee: cacheUser, chat: SendbirdChatRegister())
        let registerPushNotification = RemoteCreateUserNotificationDecorator(decoratee: registerChat, pushNotification: OneSignalPushNotificationRegister())
        
        let controller = UserBasicInfoUIComposer.inputUserComposerWith(
            inputUser: inputUser,
            create: registerPushNotification,
            usernameValidator: usernameValidator,
            emailValidator: emailValidator,
            uploader: uploader, 
            onSuccessCreateNewUser: onSuccessCreateNewUser
        )
        
        return controller
    }
}
