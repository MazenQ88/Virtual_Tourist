//
//  DataController.swift
//  VirtualTourist
//
//  Created by Mazen Al Quliti on 11/07/2019.
//  Copyright © 2019 Mazen Al Quliti. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistantContainer : NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completionHandler: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completionHandler?()
        }
    }
    
}
