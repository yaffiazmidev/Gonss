//
//  KeychainTokenStore.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 30/03/22.
//

import Foundation

public class KeychainTokenStore: TokenStore {
    
    private let store: KeychainStore
    
    private static let access_token_key = "access_token_key"
    private static let refresh_token_key = "refresh_token_key"
    private static let token_expires_key = "token_expires_key"
    
    public init(query: KeychainStoreQueryable = GenericPasswordQueryable(service: "tokenService")) {
        self.store = KeychainStore(keychainStoreQueryable: query)
    }
    
    public func insert(_ token: LocalTokenItem, completion: @escaping InsertionCompletions) {
        let expiredDateInString = TokenHelper.convertDateToString(date: token.expiresIn)
        do {
            try store.setValue(token.accessToken, for: KeychainTokenStore.access_token_key)
            try store.setValue(token.refreshToken, for: KeychainTokenStore.refresh_token_key)
            try store.setValue(expiredDateInString, for: KeychainTokenStore.token_expires_key)
            completion(.success(()))
        } catch (let error) {
            completion(.failure(error))
        }
    }
    
    public func retrieve() -> LocalTokenItem? {
        do {
            guard let accessToken = try store.getValue(for: KeychainTokenStore.access_token_key),
                  let refreshToken = try store.getValue(for: KeychainTokenStore.refresh_token_key),
                  let expiresIn = try store.getValue(for: KeychainTokenStore.token_expires_key),
                  let expiresDate = TokenHelper.convertStringToDate(dateString: expiresIn) else {
                    return nil
                  }
            return LocalTokenItem(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresDate)
        } catch {
            return nil
        }
    }
    
    public func remove() {
        do {
            try store.removeAllValues()
        } catch {} 
        
    }
}
