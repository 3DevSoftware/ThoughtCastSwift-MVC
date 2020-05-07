//
//  Drawing+Convenience.swift
//  isknApp
//
//  Created by Trevor Walker on 11/24/19.
//  Copyright © 2019 Trevor Walker. All rights reserved.
//

import UIKit
import CoreData

extension Drawing {
    
    convenience init(date: Date, image: UIImage, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.image = image.pngData() as Data?
        self.date = date
    }
}
