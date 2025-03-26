//
//  UserBasicInfoUIComposer.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class UserBasicInfoUIComposer {
    private init() {}
    
    public static func inputUserComposerWith(
        inputUser: InputUserParams,
        create: CreateUser,
        usernameValidator: UsernameValidator,
        emailValidator: EmailValidator,
        uploader: UserPhotoUploader,
        onSuccessCreateNewUser: @escaping (String) -> Void
    ) -> UserBasicInfoViewController {
        
        let emailValidatorService = EmailValidatorService(checker: MainQueueDispatchDecorator(decoratee: emailValidator))
        let createService = CreateUserService(creater: MainQueueDispatchDecorator(decoratee: create))
        let usernameValidatorService = UsernameValidatorService(checker: MainQueueDispatchDecorator(decoratee: usernameValidator))
        let uploaderService = UserPhotoUploadService(uploader: MainQueueDispatchDecorator(decoratee: uploader))
        
        let serviceFactory = InputUserServiceFactory(emailValidator: emailValidatorService, usernameValidator: usernameValidatorService, uploader: uploaderService, creater: createService)
        
        let controller = UserBasicInfoViewController(
            delegate: serviceFactory,
            inputUser: inputUser,
            onSuccessCreateNewUser: onSuccessCreateNewUser
        )
        
        emailValidatorService.presenter = EmailValidatorPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller),
            alreadyExistsView: WeakRefVirtualProxy(controller)
        )
        
        usernameValidatorService.presenter = UsernameValidatorPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller),
            alreadyExistsView: WeakRefVirtualProxy(controller)
        )
        
        uploaderService.presenter = UserPhotoUploadPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller))
        
        createService.presenter = CreateUserPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller))
        
        return controller
    }
}
