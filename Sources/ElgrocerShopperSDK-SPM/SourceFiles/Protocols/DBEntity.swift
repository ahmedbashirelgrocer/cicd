//
//  DBEntity.swift
//  ElGrocerShopper
//
//  Created by Piotr Gorzelany on 04/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
import CoreData

protocol DBEntity: class {
    
    /** The name of the db entity */
    static var entityName: String {get}
    
}

extension DBEntity where Self: NSManagedObject {
    
    static var entityName: String {
        return String(describing: Self())
    }
    
    /** Creates a new managed object */
    static func createObject(_ context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! Self
    }
    
    /** Removes the object from the Entity */
    static func deleteObject(_ object: Self) {
        
        let context = object.managedObjectContext
        context?.delete(object)
    }
    
    /** Returns objects from Entity after applying predicate */
    static func getObjects(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [], context: NSManagedObjectContext) -> [Self] {
        
        //let fetchRequest = NSFetchRequest(entityName: Self.entityName)
       /* let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Self.entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        if let objects = (try? context.fetch(fetchRequest)) as? [Self] {
            return objects
        }

        return []*/
        
        //AWAIS -- Swift4
     //  elDebugPrint("Entity Name:%@",Self.entityName)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        if let objects = (try? context.fetch(request)) as? [Self] {
            return objects
        }
        
        return []
    }
    
    /** Removes all objects from the entity table. Does not save changes. */
    static func clearEntity(_ context: NSManagedObjectContext = DatabaseHelper.sharedInstance.mainManagedObjectContext) {
        
        DatabaseHelper.sharedInstance.clearEntity(Self.entityName, context: context)
    }
    
}
