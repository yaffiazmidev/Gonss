//
//  AddAccountBankOperation.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Alamofire

class AddAccountBankOperation {
    static func listBank(request: ListBankRequest, completion: @escaping(Response<ListBankResponse>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseType<ListBankResponse>, AFError>) in
                completion(Response<ListBankResponse>.initResult(response))
            })
        } catch {}
    }
    
    static func checkAccountBank(request: CheckAccountBankRequest, completion: @escaping(Response<CheckBankAccountResponse>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseType<CheckBankAccountResponse>, AFError>) in
                completion(Response<CheckBankAccountResponse>.initResult(response))
            })
        } catch {}
    }
    
    static func requestOTP(request: OTPRequest, completion: @escaping(DataResponse<DefaultResponse, AFError>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<DefaultResponse, AFError>) in
                completion(response)
            })
        } catch {}
    }
    
    static func addAccountBank(request: AddBankRequest, completion: @escaping(DataResponse<AddAccountBankResponse, AFError>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<AddAccountBankResponse, AFError>) in
                completion(response)
            })
        } catch {}
    }
    
    static func listBankByQuery(request: SearchBankName, completion: @escaping(Response<ListBankResponse>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseType<ListBankResponse>, AFError>) in
                completion(Response<ListBankResponse>.initResult(response))
            })
        } catch {}
    }
}
