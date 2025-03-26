//
//  CoreDataLocationDonationStore.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import CoreData

public final class CoreDataLocationDonationStore {
    private static let modelName = "LocationDonationStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataLocationDonationStore.self))
                                                         
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum LocationError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataLocationDonationStore.model else {
            throw LocationError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(modelName: "LocationDonationStore", model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw LocationError.failedToLoadPersistentContainer(error)
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.perform {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

extension CoreDataLocationDonationStore: LocationDonationStore {
    func insert(_ locations: [LocalLocationDonationItem], timesStamp: Date, completion: @escaping InsertItemCompletions) {
        perform { context in
            completion(Swift.Result {
                let managedCache = try ManagedCacheLocation.newUniqueInstance(in: context)
                managedCache.timestamp = timesStamp
                managedCache.locations = ManagedLocationDonationItem.locations(from: locations, in: context)
                try context.save()
            })
        }
    }
    
    func deleteCachedLocations(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Swift.Result {
                try ManagedCacheLocation.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Swift.Result {
                try ManagedCacheLocation.find(in: context).map {
                    CachedLocationDonation(locations: $0.localLocations, timestamp: $0.timestamp)
                }
            })
        }
    }
}
