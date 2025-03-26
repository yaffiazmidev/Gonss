//
//  ReportAccountViewModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class ReportAccountViewModel {
    
    // MARK: - Public Property
    
    let networkModel: ReportNetworkModel?
    var changeHandler: ((ReportFeedViewModelChange) -> Void)?
    var imageUrl: String = ""
    var accountId: String  = ""
    var type: String = ""
    var reportType: ReportType = .FEED
    var reason: Reason = Reason()
    
    var totalCount: Int {
        return total
    }
    
    // MARK: - Private Property
    
    private var reasons = [Reason]()
    private var total: Int = 0
    
    // MARK: - Public Method
    
    init(imageUrl: String, accountId: String, indexFeed: Int = 0, networkModel: ReportNetworkModel) {
        self.networkModel = networkModel
        self.accountId = accountId
        self.imageUrl = imageUrl
    }
    
    func reason(at index: Int) -> Reason {
        return reasons[index]
    }
    
    func submitReport() {
        self.emit(.didUpdateReport)
    }
    
    func submitReportWithType() {
        self.emit(.didUpdateReport)
    }
    
    
    func fetchReason() {
        networkModel?.fetchReason(.reasonReport, { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result{
            case.failure(let error):
                print(error?.statusMessage ?? "")
                self.emit(.didEncounterError(error))
            case.success(let response):
                self.reasons = response.data ?? []
                //                self.reasons.removeLast()
                self.total = self.reasons.count
                self.emit(.didUpdateReason)
            }
        })
    }
    
    func fetchReasonComment() {
        networkModel?.fetchReason(.reasonReportComment, { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result{
            case.failure(let error):
                print(error?.statusMessage ?? "")
                self.emit(.didEncounterError(error))
            case.success(let response):
                self.reasons = response.data ?? []
                self.total = self.reasons.count
                self.emit(.didUpdateReason)
            }
        })
    }
    
    func getReasonCellViewModel(at index: Int) -> Reason? {
        
        guard index < reasons.count else {
            return nil
        }
        
        return reasons[index]
    }
    
    func emit(_ change: ReportFeedViewModelChange) {
        changeHandler?(change)
    }
    
}
