//
//  DonationCartManager.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 31/01/24.
//

import Foundation
import KipasKipasShared

public class DonationCartManagerNotification {
    public static let updated = Notification.Name(rawValue: "DonationCartManagerNotification.updated")
    
    private init () {}
}

public enum DonationCartCheckStatus {
    case none
    case partial
    case all
}

public class DonationCartManager {
    
    private static var _instance: DonationCartManager?
    private static let lock = NSLock()
    
    private let logId = "DonationCartManager"
    private var userId: String = "guest"
    public var data: [DonationCart] = []
    
    public static var instance: DonationCartManager {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = DonationCartManager()
            }
        }
        return _instance!
    }
    
    private init() {}
}

public extension DonationCartManager {
    func login(user id: String) {
        guard !id.isEmpty else {
            print(logId, "login: failure because empty id, using guest data")
            return
        }
        userId = id
        loadData()
        print(logId, "login: success", id)
    }
    
    func logout() {
        userId = "guest"
        data = []
        loadData()
        print(logId, "logout")
    }
}

public extension DonationCartManager {
    func add(_ data: DonationCart) {
        if isAdded(id: data.id) {
            print(logId, "add data: already exist")
            return
        }
        
        self.data.append(data)
        dataChanged()
        print(logId, "add data: success")
    }
    
    func update(_ data: DonationCart) {
        guard let index = self.data.firstIndex(where: {$0.id == data.id}) else {
            print(logId, "update data: not found")
            return
        }
        
        self.data[index] = data
        dataChanged()
        print(logId, "update data: success")
    }
    
    func remove(_ data: DonationCart) {
        self.data.removeAll(where: {$0.id == data.id})
        dataChanged()
        print(logId, "remove data: success")
    }
    
    func checkAll() {
        guard !data.isEmpty else {
            print(logId, "checkAll: data empty")
            return
        }
        
        for i in 0..<data.count {
            data[i].checked = true
        }
        dataChanged()
        print(logId, "checkAll: success")
    }
    
    func uncheckAll() {
        guard !data.isEmpty else {
            print(logId, "uncheckAll: data empty")
            return
        }
        
        for i in 0..<data.count {
            data[i].checked = false
        }
        dataChanged()
        print(logId, "uncheckAll: success")
    }
    
    func clearChecked() {
        guard !data.isEmpty else {
            print(logId, "clearChecked: data empty")
            return
        }
        
        data.removeAll(where: {$0.checked})
        dataChanged()
        print(logId, "clearChecked: success")
    }
    
    func clear() {
        data.removeAll()
        dataChanged()
        print(logId, "clear: success")
    }
    
    func isAdded(id: String) -> Bool {
        return data.contains(where: {$0.id == id})
    }
}

private extension DonationCartManager {
    func dataChanged() {
        saveData()
        NotificationCenter.default.post(name: DonationCartManagerNotification.updated, object: nil)
    }
    
    func key() -> KKCache.Key {
        return KKCache.Key("DonationCart-\(userId)")
    }
    
    func loadData() {
        let dataCache = KKCache.common.readData(key: key())
        guard let dataCache = dataCache,
              let cache = try? JSONDecoder().decode([DonationCart].self, from: dataCache)
        else {
            print(logId, "loadData fail")
            return
        }
        
        print(logId, "loadData success")
        data = cache
        NotificationCenter.default.post(name: DonationCartManagerNotification.updated, object: nil)
    }
    
    func saveData() {
        guard let data = try? JSONEncoder().encode(data) else {
            print(logId, "saveData fail")
            return
        }
        
        KKCache.common.save(data: data, key: key())
        print(logId, "saveData success")
    }
}

public extension Array where Element == DonationCart {
    func checkedStatus() -> DonationCartCheckStatus {
        guard !isEmpty else {
            return .none
        }
        
        let containsTrue = contains(where: {$0.checked == true})
        let containsFalse = contains(where: {$0.checked == false})
        
        if containsTrue && containsFalse {
            return .partial
        } else if containsTrue {
            return .all
        } else {
            return .none
        }
    }
}
