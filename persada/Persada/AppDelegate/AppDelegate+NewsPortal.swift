//
//  AppDelegate+NewsPortal.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 12/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

fileprivate let newsPortalVersion = 3

extension AppDelegate {
    func configureNewsPortal() {
        if (KKCache.common.readInteger(key: .newsPortalVersion) ?? 0) < newsPortalVersion {
            KKCache.common.save(integer: newsPortalVersion, key: .newsPortalVersion)
            KKCache.common.remove(key: .newsPortalQuickAccess)
        }
    }
}
