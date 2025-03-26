//
//  WithdrawalBalanceOperation.swift
//  KipasKipas
//
//  Created by iOS Dev on 25/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Alamofire

class WithdrawalBalanceOperation {
    var managerAPI: KKAPIManager = KKAPIManager()
    
    static func info(request: WithdrawalBalanceInfoRequest, completion: @escaping(Response<WithdrawalBalanceInfoResponse>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseType<WithdrawalBalanceInfoResponse>, AFError>) in
                completion(Response<WithdrawalBalanceInfoResponse>.initResult(response))
            })
        } catch {}
    }
    
    static func listBankUser(request: ListBankAccountUserRequest, completion: @escaping(Response<[ListBankAccountUserResponse]>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseArrayType<ListBankAccountUserResponse>, AFError>) in
                completion(Response<[ListBankAccountUserResponse]>.initArrayResult(response))
            })
        } catch {}
    }
    
    static func VerifyPassword(request: VerifyPasswordRequest, completion: @escaping(Response<(Bool)>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable { (response:
                DataResponse<GeneralResponseBoolType, AFError>) in
                completion(Response<(Bool)>.initBoolResult(response))
            }
        } catch {}
    }
    
    static func WithdrawalBalance(request: WithdrawalBalanceRequest, completion: @escaping(Response<WithdrawalBalanceInfoResponse>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable { (response:
                DataResponse<GeneralResponseType<WithdrawalBalanceInfoResponse>, AFError>) in
                completion(Response<WithdrawalBalanceInfoResponse>.initWithdrawalResult(response))
            }
        } catch {}
    }
    
    static func deleteBankAccount(request: DeleteBankAccountRequest, completion: @escaping(Response<WithdrawalBalanceInfoResponse>) -> Void) {
        do {
            try KKAPIManager().execute(request: request).responseDecodable { (response:
                DataResponse<GeneralResponseType<WithdrawalBalanceInfoResponse>, AFError>) in
                completion(Response<WithdrawalBalanceInfoResponse>.initWithdrawalResult(response))
            }
        } catch {}
    }
}
