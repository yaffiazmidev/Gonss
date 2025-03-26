//
//  SendbirdChatRegister.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//


import Foundation
import KipasKipasDirectMessage
import SendbirdChatSDK

class SendbirdChatRegister: ChatRegister {
    
    func register(request: ChatRegisterRequest) {
        /*
        UserConnectionUseCase.shared.login(userId: request.accountlID) { [weak self] result in
            
            switch result {
            case .success(_):
                
                let params = UserUpdateParams()
                params.nickname = request.username
                
                self?.downloadImageData(urlString: request.avatar) { data in
                    params.profileImageData = data
                }
               
                SendbirdChat.updateCurrentUserInfo(params: params, completionHandler:  { error in
                    if let error = error {
                        print("SendbirdChat: Error \(error.localizedDescription)")
                        return
                    }
                    
                    print("SendbirdChat: Success update current user info")
                })
                
            case .failure(let error):
                print("SendbirdChat: Failed connect to sendbird \(error.localizedDescription)")
            }
        }
         */
    }
    
    private func downloadImageData(urlString: String, completion: @escaping ((Data?) -> Void)) {
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL..")
            completion(nil)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Error: Data not found..")
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
}
