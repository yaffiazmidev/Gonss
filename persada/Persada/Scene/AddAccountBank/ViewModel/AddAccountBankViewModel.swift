//
//  AddAccountBankViewModel.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddAccountBankViewModel {
    var bankChoice = BehaviorRelay<DataBank?>(value: nil)
    var bankCheck = BehaviorRelay<AccountDestinationModel?>(value: nil)
    var isLoading = BehaviorRelay<Bool?>(value: nil)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    var noRek = BehaviorRelay<String?>(value: nil)
    var isRekValid = BehaviorRelay<Bool?>(value: nil)
    var textAccountNumber = BehaviorRelay<String?>(value: nil)
    
    var pages = 0
    var totalPages: Int?
    var bank: [DataBank] = []
    var isSearch = false
    
    func fetchBankList() {
        if pages == 0 {
            bank = []
        }
        
        if pages == 0 || pages < totalPages ?? 1 {
            let request = ListBankRequest(pages: pages)
            isLoading.accept(true)
            AddAccountBankOperation.listBank(request: request) { result in
                switch result {
                case .success(let data):
                    let dataBank = data.content.map({ (bank) -> DataBank in
                        return DataBank(id: bank?.id ?? "", namaBank: bank?.name ?? "", bankCode: bank?.bankCode ?? "")
                    })
                    
                    self.bank.append(contentsOf: dataBank)
                    guard let last = data.last, let total = data.totalPages else { return }
                    
                    if !last {
                        self.pages += 1
                        self.totalPages = total
                    }
                    self.isLoading.accept(false)
                    
                case .failure(let error):
                    self.errorMessage.accept("\(error)")
                    self.isLoading.accept(false)
                    
                case .error:
                    self.errorMessage.accept("Failed Network Message")
                    self.isLoading.accept(false)
                }
            }
        }
    }
    
    func fetchBankListByQuery(query: String) {
        let request = SearchBankName(query: query)
        isLoading.accept(true)
        AddAccountBankOperation.listBankByQuery(request: request) { result in
            switch result {
            case .success(let data):
                let dataBank = data.content.map({ (bank) -> DataBank in
                    return DataBank(id: bank?.id ?? "", namaBank: bank?.name ?? "", bankCode: bank?.bankCode ?? "")
                })
                
                self.bank = dataBank
                self.isLoading.accept(false)
                
            case .failure(let error):
                self.errorMessage.accept("\(error)")
                self.isLoading.accept(false)
                
            case .error:
                self.errorMessage.accept("Failed Network Message")
                self.isLoading.accept(false)
            }
        }
    }
    
    func checkBankAccount() {
        guard let bankChoice = bankChoice.value, let text = textAccountNumber.value else { self.errorMessage.accept("ada field yang belum terisi")
            return
        }
        
        let request = CheckAccountBankRequest(bankCode: bankChoice.bankCode ?? "", accountNumber: text)
        self.isLoading.accept(true)
        AddAccountBankOperation.checkAccountBank(request: request) { result in
            self.isLoading.accept(false)
            switch result {
            case .success(let data):
                if let bankCode = data.bankCode, let nama = data.accountName, let bankName = data.bankName {
                    self.bankCheck.accept(AccountDestinationModel(id: bankCode,
                                                                  namaBank: bankName,
                                                                  noRek: data.accountNumber,
                                                                  nama: nama,
                                                                  swiftCode: nil, withdrawFee: 0))
                    self.isRekValid.accept(true)
                } else {
                    self.isRekValid.accept(false)
                }
                
            case .failure(let error):
//                self.isRekValid.accept(false)
                self.errorMessage.accept(error.statusMessage)
                
            case .error:
                self.isRekValid.accept(false)
//                self.errorMessage.accept("Failed networking")
            
            }
        }
        
    }
}
