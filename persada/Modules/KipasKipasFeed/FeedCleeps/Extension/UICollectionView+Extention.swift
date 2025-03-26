//
//  Ext-UICollectionView.swift
//  FeedCleeps
//
//  Created by koanba on 28/02/23.
//

import Foundation
import UIKit
import Sentry
import Disk

internal extension UICollectionView {
    func isCellAtIndexPathFullyVisible(_ indexPath: IndexPath) -> Bool {
        
        guard let layoutAttribute = layoutAttributesForItem(at: indexPath) else {
            return false
        }
        
        let cellFrame = layoutAttribute.frame
        return self.bounds.contains(cellFrame)
    }
    
    func indexPathsForFullyVisibleItems() -> [IndexPath] {
        
        let visibleIndexPaths = indexPathsForVisibleItems
        
        return visibleIndexPaths.filter { indexPath in
            return isCellAtIndexPathFullyVisible(indexPath)
        }
    }
}

internal extension UICollectionView {
    private func getUsername() -> String? {
        let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: Login.self)
        return data?.userName
    }
    
    func notifSentry(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column){
        self.sendToSentry(message, file: file, function: function, line: line, column: column)
    }
    
    private func sendToSentry(_ message: String, file: String, function: String, line: Int, column: Int) {
        let filename = String(describing: file.split(separator: "/").last)
        
        let user = User()
        user.userId = "\(UIDevice.current.name)"
        if let username = getUsername() {
            user.username = username
        }
        
        SentrySDK.setUser(user)
        SentrySDK.capture(message: "INFO : Error handler for Collection View\nError \(message) from file/class \(filename), function \(function), line \(line), column \(column)")
    }
    
    func safeInsertItems(at indexPaths: [IndexPath], completion: ((Bool) -> Void)? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        let indexPathVisible = self.indexPathsForVisibleItems
        var containVisibleCell = false
        for indexPath in indexPaths {
            if indexPathVisible.contains(where: { $0 == indexPath }){
                containVisibleCell = true
                break
            }
        }
        
        
        if containVisibleCell {
            reloadItems(at: indexPaths)
            return
        }
        
        var differentSection = false
        for visible in indexPathVisible {
            for indexPath in indexPaths {
                if visible.section != indexPath.section {
                    differentSection = true
                    break
                }
            }
        }
        
        var containChangeInAnotherSection = false
        if self.numberOfSections > 0 && !differentSection {
            for i in 0..<self.numberOfSections{
                if i != indexPaths.first?.section && self.numberOfItems(inSection: i) > 0 {
                    containChangeInAnotherSection = true
                    break
                }
            }
        }
        print("PE-10545", indexPathVisible, indexPathVisible.first?.section , "#", indexPaths, indexPaths.first?.section, self.window == nil, function, line, containVisibleCell, differentSection, containChangeInAnotherSection)
        
        if self.window == nil || self.indexPathsForVisibleItems.isEmpty || differentSection || containChangeInAnotherSection {
            self.reloadData()
            return
        }
        
        print("PE-10545", self.window == nil, "safeInsertItems", self.indexPathsForVisibleItems, indexPaths, function, line)
        self.performBatchUpdates({
            // Perform batch updates within this block
            // Insert new items to the collection view's data source
            // For example, you can use an array called "newItems" to hold the new items
            self.insertItems(at: indexPaths)
            
            // After inserting the new items, call reloadItems to update the collection view's layout
            self.customReloadItems(at: indexPaths)
        }, completion: { (finished) in
            completion?(finished)
        })
        
    }
    
    func safeDeleteItems(at indexPaths: [IndexPath], completion: ((Bool) -> Void)? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        let indexPathVisible = self.indexPathsForVisibleItems
        var containsAnotherSection = false
        for i in 0..<self.numberOfSections {
            indexPathVisible.forEach { visible in
                if visible.section != i {
                    if self.numberOfItems(inSection: i) > 0 {
                        containsAnotherSection = true
                    }
                }
            }
        }
        
        if containsAnotherSection {
            self.reloadData()
            completion?(true)
            return
        }
        
        self.performBatchUpdates({
            self.deleteItems(at: indexPaths)
        }, completion: { (finished: Bool) in
            completion?(finished)
        })
    }
    
    func customReloadItems(at indexPaths: [IndexPath], file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        
        let indexPathVisible = self.indexPathsForVisibleItems
        var containVisibleCell = false
        for indexPath in indexPaths {
            if indexPathVisible.contains(where: { $0 == indexPath }){
                containVisibleCell = true
                break
            }
        }
        
        print("PE-10494", self.window == nil, "customReloadItems", indexPaths, function, line)
        if containVisibleCell { //reload items is performed only on visible cells
            print("10245 - reloadSection for visibleCell")
            //            reloadItems(at: indexPaths)
            if indexPaths.contains(where: {$0.item == 0 }) {
                print("10245 - reloadSection for visibleCell contain index 0")
                let section = checkSection(for: indexPaths)
                if section.isSame && section.section != nil {
                    print("10245 - reloadSection for visibleCell with same section", section.section!)
                    customReloadSections(IndexSet(integer: section.section!))
                } else {
                    reloadData()
                }
                return
            }
            print("10245 - reloadSection for visibleCell, reloadItems")
            reloadItems(at: indexPaths)
            return
        }
        
        //        reloadItems(at: indexPaths)
    }
    
    private func checkSection(for indexPaths: [IndexPath]) -> (isSame: Bool, section: Int?) {
        if let firstSection = indexPaths.first?.section {
            return (indexPaths.contains(where: { $0.section == firstSection }), firstSection)
        }
        return (false, nil)
    }
    
    func customReloadSections(_ sections: IndexSet, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        var valid = true
        for section in sections {
            if numberOfItems(inSection: section) < 1 {
                valid = false
                break
            }
        }
        
        if valid {
            reloadSections(sections)
        } else {
            //sendToSentry("reload sections for \(sections)", file: file, function: function, line: line, column: column)
            reloadData()
        }
    }
}

fileprivate struct Login: Codable {
    var accessToken, tokenType, loginRefreshToken: String?
    var expiresIn: Int?
    var scope: String?
    var userNo: Int?
    var userName, userEmail, userMobile, accountId: String?
    var authorities: [String]?
    var appSource, code: String?
    var timelapse: Int?
    var avatar: String?
    var role, jti, token, refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case loginRefreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope, userNo, userName, userEmail, userMobile, accountId, authorities, appSource, code, timelapse, role, jti, token, refreshToken, avatar
    }
}
