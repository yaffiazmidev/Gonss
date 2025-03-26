//
//  HistoryTransactionOperation.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Alamofire

class HistoryTransactionOperation {
    var managerAPI: KKAPIManager
    
    init(managerAPI: KKAPIManager = KKAPIManager()) {
        self.managerAPI = managerAPI
    }
    
    func list(request: HistoryTransactionRequest, completion: @escaping(Response<HistoryTransactionResponse>) -> Void) {
        do {
            try managerAPI.execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseType<HistoryTransactionResponse>, AFError>) in
                completion(Response<HistoryTransactionResponse>.initResult(response))
            })
        } catch {}
    }
    
    func listFilter(request: HistoryTransactionFilterRequest, completion: @escaping(Response<HistoryTransactionResponse>) -> Void) {
        do {
            try managerAPI.execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseType<HistoryTransactionResponse>, AFError>) in
                completion(Response<HistoryTransactionResponse>.initResult(response))
            })
        } catch {}
    }
    
    func detailTransaction(request: HistoryTransactionDetailRequest, completion: @escaping(Response<HistoryTransactionDetailOrderResponse>) -> Void) {
        do {
            try managerAPI.execute(request: request).responseDecodable(completionHandler: { (response: DataResponse<GeneralResponseType<HistoryTransactionDetailOrderResponse>, AFError>) in
                completion(Response<HistoryTransactionDetailOrderResponse>.initResult(response))
            })
        } catch {}
    
    }
    
    func detailRefund(request: HistoryTransactionDetailRequest, completion: @escaping(Response<HistoryTransactionDetailRefundResponse>) -> Void) {
        do {
            try managerAPI.execute(request: request).responseDecodable(completionHandler: { (response:
                DataResponse<GeneralResponseType<HistoryTransactionDetailRefundResponse>, AFError>) in
                completion(Response<HistoryTransactionDetailOrderResponse>.initResult(response))
            })
        } catch {}
    }
}
