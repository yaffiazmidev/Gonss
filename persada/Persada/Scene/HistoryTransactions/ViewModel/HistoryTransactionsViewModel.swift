//
//  HistoryTransactionsViewModel.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import RxCocoa
import RxSwift

class HistoryTransactionsViewModel {
    var data = BehaviorRelay<[HistoryTransactionModel]>(value: [])
    var dataManipulation = BehaviorRelay<[HistoryTransactionModel]>(value: [])
    var dataFilter = BehaviorRelay<[HistoryTransactionModel]>(value: [])
    var query = BehaviorRelay<String?>(value: nil)
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    var dateFrom = BehaviorRelay<String?>(value: nil)
    var dateTo = BehaviorRelay<String?>(value: nil)
    var transactionType = BehaviorRelay<String?>(value: nil)
    var isFilterData = BehaviorRelay<Bool>(value: false)
    
    var operation: HistoryTransactionOperation
    
    init(operation: HistoryTransactionOperation = HistoryTransactionOperation()) {
        self.operation = operation
    }
    
    func fetchData() {
        let request = HistoryTransactionRequest()
        isLoading.accept(true)
        
        operation.list(request: request) { result in
            self.isLoading.accept(false)
            
            switch result {
            case .success(let data):
                self.data.accept(data.histories.map { (history) -> HistoryTransactionModel in
                    
                    return HistoryTransactionModel(
                        date: history.createAt,
                        currency: history.nominal,
                        historyType: history.historyType,
                        noInvoice: history.noInvoice,
                        activity: history.activityType,
                        orderId: history.orderId,
                        bankFee: history.bankFee ?? nil,
                        bankAccountName: history.bankAccountName ?? nil,
                        bankAccountNumber: history.bankAccountNumber ?? nil,
                        bankName: history.bankName ?? nil
                    )
                    
                })
                self.dataManipulation.accept(self.data.value)
            
            case .failure(_):
                self.errorMessage.accept("gagal mendapatkan data")
                
            case .error:
                self.errorMessage.accept("Failed Networking Message")
            }
            self.isLoading.accept(false)
        }
    }
    
    func fetchBySearch() {
        self.isLoading.accept(true)
        
        guard let query = query.value else {
            self.isLoading.accept(false)
            self.errorMessage.accept("belum ada query")
            return
        }
        
        
        var value = data.value
        
        if isFilterData.value {
            value = dataFilter.value
        }
        
        let dataFilter = value.filter { data in
            guard let invoice = data.noInvoice else { return false }
            return invoice.containsIgnoringCase(find: query)
        }
        
        self.dataManipulation.accept(dataFilter)
        self.query.accept(nil)
        self.isLoading.accept(false)
    }
    
    func fetchByFilter() {
        guard let dateFromString = dateFrom.value, let dateToString = dateTo.value, let transactionType = transactionType.value else { return }
        let dateFrom = dateFromString.toDate().startOfDay.millisecondsSince1970
        let dateTo = dateToString.toDate().endOfDay.millisecondsSince1970
        
        let request = HistoryTransactionFilterRequest(dateFrom: Int(dateFrom), dateTo: Int(dateTo), typeTransaction: transactionType)
        
        self.isLoading.accept(true)
        operation.listFilter(request: request) { result in
            
            switch result {
            case .success(let data):
                self.dataFilter.accept(data.histories.map { (history) -> HistoryTransactionModel in
                    
                    return HistoryTransactionModel(
                        date: history.createAt,
                        currency: history.nominal,
                        historyType: history.historyType,
                        noInvoice: history.noInvoice,
                        activity: history.activityType,
                        orderId: history.orderId,
                        bankFee: history.bankFee ?? nil,
                        bankAccountName: history.bankAccountName ?? nil,
                        bankAccountNumber: history.bankAccountNumber ?? nil,
                        bankName: history.bankName ?? nil
                    )
                    
                })
                self.dataManipulation.accept(self.dataFilter.value)
                
            case .failure (_):
                self.errorMessage.accept("Gagal menggunakan filter")
                self.isLoading.accept(false)
            case .error:
                self.errorMessage.accept("Gagal menggunakan filter")
                self.isLoading.accept(false)
            }
            self.isLoading.accept(false)
        }
    }
}
