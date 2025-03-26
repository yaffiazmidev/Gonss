//
//  ManagedCacheLocation.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import CoreData

@objc(ManagedCacheLocation)
class ManagedCacheLocation: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var locations: NSOrderedSet
}

extension ManagedCacheLocation {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCacheLocation? {
        let request = NSFetchRequest<ManagedCacheLocation>(entityName: ManagedCacheLocation.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCacheLocation {
        try find(in: context).map(context.delete)
        return ManagedCacheLocation(context: context)
    }
    
    var localLocations: [LocalLocationDonationItem] {
        return locations.compactMap { ($0 as? ManagedLocationDonationItem)?.local }
    }
}

