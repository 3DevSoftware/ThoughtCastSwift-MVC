//
//  CoreDataStack.swift
//  isknApp
//
//  Created by Trevor Walker on 11/24/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "NeoPenDemo")
        container.loadPersistentStores { (storeDescroption, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext {return container.viewContext}
}
