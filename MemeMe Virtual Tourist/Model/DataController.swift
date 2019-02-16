//
//  DataController.swift
//  MemeMe Virtual Tourist
//
//  Created by Hessa Mohamed on 05/02/2019.
//  Copyright © 2019 Hessa Mohamed. All rights reserved.
//

import Foundation

import Foundation
import CoreData

class DataController {
    
    static let shared = DataController()
    
    private let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init() {
        persistentContainer = NSPersistentContainer(name: "MemeMe_Virtual_Tourist")
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
