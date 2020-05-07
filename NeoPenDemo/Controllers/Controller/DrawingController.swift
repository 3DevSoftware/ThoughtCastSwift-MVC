//
//  DrawingController.swift
//  isknApp
//
//  Created by Trevor Walker on 11/24/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit
import CoreData

class DrawingController {
    // MARK: - Properties
    static let shared = DrawingController()
    
    var drawings: [Drawing] {
        //grabbing managed object context
        let moc = CoreDataStack.context
        //Creating a fetch request
        let fetchRequest: NSFetchRequest<Drawing> = Drawing.fetchRequest()
        //Does the fetch Request
        let results = try? moc.fetch(fetchRequest)
        //Returns our results, if nil returns an empty array
        if let results = results {
            return results.sorted(by: {
            $0.date!.compare($1.date!) == .orderedDescending})
        }
        return []
    }
    
    // MARK: - CRUD Functions
    
    func createDrawing(date: Date, image: UIImage){
        _ = Drawing(date: date, image: image)
        saveToPersistantStore()
    }
    
    func deleteDrawing(drawings: [Drawing]) {
        let moc = CoreDataStack.context
        for drawing in drawings {
            moc.delete(drawing)
        }
        saveToPersistantStore()
    }
    //Saves to core data
    func saveToPersistantStore() {
        let moc = CoreDataStack.context
        do {
            try moc.save()
        } catch {
            print("Error saving to persistant store. \(error.localizedDescription): \(error)")
        }
    }
}
