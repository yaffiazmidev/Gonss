//
//  ManagedLocationDonationItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 08/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import CoreData

@objc(ManagedLocationDonationItem)
class ManagedLocationDonationItem: NSManagedObject {
    @NSManaged var code: String
    @NSManaged var id: String
    @NSManaged var name: String
}

extension ManagedLocationDonationItem {
    static func locations(from localLocations: [LocalLocationDonationItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localLocations.map {
            let managed = ManagedLocationDonationItem(context: context)
            managed.id = $0.id
            managed.name = $0.name
            managed.code = $0.code
            return managed
        })
    }
    
    var local: LocalLocationDonationItem {
        return LocalLocationDonationItem(id: id, name: name, code: code)
    }
}
    

