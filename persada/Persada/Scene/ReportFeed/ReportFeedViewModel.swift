//
//  ReportFeedViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 19/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class ReportFeedViewModel {
    
    // MARK: - Public Property
    
    let networkModel: ReportNetworkModel?
    var changeHandler: ((ReportFeedViewModelChange) -> Void)?
    var imageUrl: String = ""
    var id: String = ""
    var accountId: String  = ""
    var type: String = ""
    var indexFeed: Int = 0
    var reportType: ReportType = .FEED
    var reason: Reason = Reason()
    
    var totalCount: Int {
        return total
    }
    
    // MARK: - Private Property
    
    private var reasons = [Reason]()
    private var total: Int = 0
    
    // MARK: - Public Method
    
    init(id: String, imageUrl: String, accountId: String, indexFeed: Int = 0, networkModel: ReportNetworkModel) {
        self.networkModel = networkModel
        self.id = id
        self.accountId = accountId
        self.imageUrl = imageUrl
        self.indexFeed = indexFeed
    }
    
    func reason(at index: Int) -> Reason {
        return reasons[index]
    }
    
    func submitReport() {
        networkModel?.submitReport(.report(id: id, reasonRequest: reason, type: type), { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error?.statusMessage ?? "")
                self.emit(.didEncounterError(error))
            case .success(_):
                self.emit(.didUpdateReport)
            }
        })
    }
    
    func submitReportWithType() {
        networkModel?.submitReport(.report(id: id, reasonRequest: reason, type: reportType.rawValue), { [weak self] (result) in
            
            guard let self = self else { return }
            
            if self.type == ReportType.COMMENT.rawValue {
                NotificationCenter.default.post(name: .handleReportComment, object: nil, userInfo: ["id": self.id, "result": result])
            }
            
            switch result {
            case .failure(let error):
                print(error?.statusMessage ?? "")
                self.emit(.didEncounterError(error))
            case .success(_):
                self.emit(.didUpdateReport)
            }
        })
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
                //				self.reasons.removeLast()
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
                //                self.reasons.removeLast()
                self.total = self.reasons.count
                self.emit(.didUpdateReason)
            }
        })
    }
    
    func fetchReasonSubcomment() {
        networkModel?.fetchReason(.reasonReportSubcomment, { [weak self] (result) in
            
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

enum ReportFeedViewModelChange {
    case didUpdateReport
    case didUpdateReason
    case didEncounterError(ErrorMessage?)
}

enum ReportType : String {
    case FEED, COMMENT, COMMENT_SUB, DECLINE_ORDER, COMPLAINT, OTHERS, BANNED_PRODUCT ,LIVE_STREAMING
}

