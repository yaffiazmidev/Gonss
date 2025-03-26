//
//  InAppPurchasePendingManager.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/10/23.
//

import Foundation
import KipasKipasNetworking

/**
 InAppPurchasePendingManager, for handle auto retry hit purchase BE after success purchase product from Appstore
 */
public class InAppPurchasePendingManager {
    private static var _instance: InAppPurchasePendingManager? // Sebagai Instance utama
    private static let lock = NSLock() // digunakan untuk mengamankan multithread
    
    private let identifier = "InAppPurchasePendingManager"
    private var data: [InAppPurchasePending] = []
    private var timer: Timer?
    private var userId: String?
    private var validator: CoinInAppPurchaseValidator?
    
    /**
     Get Instance of InAppPurchasePendingManager
     - returns: InAppPurchasePendingManager
     
     # Example #
     ```
     // InAppPurchasePendingManager.instance
     ```
     */
    public static var instance: InAppPurchasePendingManager { // Merupakan Lazy var, variable akan terbentuk ketika dipanggil saja
        if _instance == nil { // Instance pertama, masih nil
            lock.lock() // Untuk mengunci NSLock, jadi tidak bisa terjadi multi instance
            defer { // Memastikan NSLock dibuka setelah inisialisasi selesai
                lock.unlock()
            }
            if _instance == nil {
                _instance = InAppPurchasePendingManager()
            }
        }
        return _instance!
    }
    
    private init() {}
    
    
    /**
     Initialize InAppPurchaseManager. For check pending transactions and perform auto retry.
     
     - parameter baseUrl: URL.
     - parameter userId: String.
     - parameter client: HTTPClient (Authenticated).
     
     
     # Notes: #
     1. Do every open application
     2. Call any changes to parameters
     
     # Example #
     ```
     // InAppPurchasePendingManager.instance.initialize(baseUrl: URL(string: "https://api.kipaskipas.com/api/v1"), userId: "userId", client: authenticatedHTTPClient)
     ```
     */
    public func initialize(baseUrl: URL, userId: String, client: HTTPClient) {
        print(identifier, userId, type(of: client))
        
        self.userId = userId
        self.validator = RemoteCoinInAppPurchaseValidator(url: baseUrl, client: client)
        
        load()
        print(identifier, "number of pending transactions:", data.count)
        checkTimer()
    }
    
    /**
     Destroy InAppPurchasePendingManager. To set the variable to nil and stop auto retry.
     
     # Notes: #
     1. Call every user session ends
     
     # Example #
     ```
     // InAppPurchasePendingManager.instance.destroy()
     ```
     */
    public func destroy() {
        print(identifier, "destroying...")
        userId = nil
        validator = nil
        data = []
        stop()
    }
    
    
    /**
     To add pending transaction data and trigger auto retry.
     
     - parameter with data: InAppPurchasePending.
     
     
     # Notes: #
     1. Call this function every time you successfully make a purchase to the Appstore.
     
     # Example #
     ```
     // InAppPurchasePendingManager.instance.add(with: InAppPurchasePending(transactionId: transactionIdentifier, type: .coin))
     ```
     */
    public func add(with data: InAppPurchasePending) {
        if self.data.contains(where: { $0.transactionId == data.transactionId }) {
            print(identifier, "ID", data.transactionId, "has registered")
            return
        }
        
        print(identifier, "add pending transacion with id:", data.transactionId, "type:", data.type)
        self.data.append(data)
        save()
        checkTimer()
    }
    
    
    /**
     To remove pending transaction by transaction id. Check auto retry. If the data is empty, the timer stops, if there is still data, the timer continues.
     
     - parameter transaction id: String.
     
     # Notes: #
     1. Call this function when the purchase transaction to the BackEnd is in the success category & has been registered with the InAppPurchasePendingManager previously.
     
     # Example #
     ```
     // InAppPurchasePendingManager.instance.remove(transaction: transactionIdentifier)
     ```
     */
    public func remove(transaction id: String){
        print(identifier, "remove pending transacion with id:", id)
        data.removeAll(where: { $0.transactionId == id })
        save()
        checkTimer()
    }
    
    
    /**
     To clear pending data and stop the timer
     
     # Example #
     ```
     // InAppPurchasePendingManager.instance.clear()
     ```
     */
    public func clear() {
        print(identifier, "clear all pending transacion")
        data = []
        save()
        checkTimer()
    }
}

// MARK: - Cache
fileprivate extension InAppPurchasePendingManager {
    private func userDefaultsKey() -> String {
        return "\(identifier)-\(userId ?? "")"
    }
    
    private func save() {
        guard !(userId?.isEmpty ?? true) else { return }
        
        let data = data.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: userDefaultsKey())
    }
    
    private func load() {
        guard !(userId?.isEmpty ?? true) else {
            data = []
            return
        }
        
        print(identifier, "load userDefaults with key:", userDefaultsKey())
        if let data = UserDefaults.standard.array(forKey: userDefaultsKey()) as? [Data],
           let list = data.map({ try? JSONDecoder().decode(InAppPurchasePending.self, from: $0 )}) as? [InAppPurchasePending] {
            self.data = list
        }
    }
    
    private func swap() {
        if let first = data.first {
            print(identifier, "swapping first transaction to last with id:", first.transactionId)
            remove(transaction: first.transactionId)
            add(with: first)
        }
    }
}

// MARK: - Scheduler
fileprivate extension InAppPurchasePendingManager {
    private func checkTimer() {
        if data.isEmpty {
            if timer != nil {
                print(identifier, "Stop scheduler because data empty")
                stop()
            }
        } else {
            if timer == nil {
                print(identifier, "Starting scheduler")
                start()
            }
        }
    }
    
    private func start() {
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(retry), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        print(identifier, "Scheduler started:", timer != nil)
    }
    
    private func stop(){
        timer?.invalidate()
        timer = nil
        print(identifier, "Scheduler stopped:", timer == nil)
    }
    
    @objc private func retry() {
        print(identifier, "retry")
        if let data = data.first { // if the data on the first index is available
            if data.type == .coin {
                validateCoin(data: data)
            }
        } else { // data is empty
            checkTimer()
        }
    }
}

// MARK: - Network
fileprivate extension InAppPurchasePendingManager {
    private func validateCoin(data: InAppPurchasePending) {
        if let validator = validator { // check if validator has instance
            let request = CoinInAppPurchaseValidatorRequest(storeId: "e7b0c0a4-8c1f-4db8-a403-4eca7c6fdb2c", transactionId: data.transactionId)
            
            validator.validate(request: request) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    
                case .success(let data):
                    print(self.identifier, "success validate coin with id:", request.transactionId, "data:", data, ". Removing from queue")
                    self.remove(transaction: request.transactionId)
                    
                case .failure(let error):
                    print(self.identifier, "failure validate coin with id:", request.transactionId, "error:", error)
                    if let error = error as? CoinInAppPurchaseValidateError {
                        if error == .alreadyValidated {
                            print(self.identifier, "transaction:", request.transactionId, "has already registered. Removing from queue")
                            self.remove(transaction: request.transactionId)
                            return
                        }
                    }
                    
                    self.swap()
                }
                
                self.checkTimer() // for check if data empty, stop scheduler
            }
        } else { // instance nil or has destroyed
            checkTimer()
        }
    }
}
