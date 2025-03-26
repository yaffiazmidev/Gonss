//
//  FollowingUsers.swift
//  FeedCleeps
//
//  Created by DENAZMI on 12/01/23.
//

import Foundation

class FollowingUsers {
    
    static let shared = FollowingUsers()
    
    private let key = "saveLocalFollowingUsers"
    private var users: [[String: Any]] = []
    private let userDefaults = UserDefaults.standard
    
    init() {
//        .set(users, forKey: key)
    }
    
    func save(id: String, isFollow: Bool, name: String, photo: String) {
        let inComingUSer: [String: Any] = ["id": id, "isFollow": isFollow, "name": name, "photo": photo]
        
        if users.contains(where: { $0["id"] as? String == id }) {
            if !isFollow {
                users = users.filter { $0["id"] as? String != id }
            }
            
            userDefaults.set(users, forKey: key)
        } else {
            if isFollow {
                users.append(contentsOf: [inComingUSer])
                userDefaults.set(users, forKey: key)
            }
        }
        print("@@@@ saved users = \(users)")
    }
    
    func getUsers() -> [[String: Any]] {
        let getUsers = userDefaults.array(forKey: key) as? [[String: Any]] ?? [[:]]
        users = getUsers
        //print("@@@@ get users \(users)")
        return users
    }
    
    func removeUsers() {
        users.removeAll()
        userDefaults.set(users, forKey: key)
    }
}
