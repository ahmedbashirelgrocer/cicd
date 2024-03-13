//
//  ChefUser+CoreDataProperties.swift
//  
//
//  Created by M Abubaker Majeed on 19/04/2019.
//
//

import Foundation
import CoreData


let chefUserEntityName = "ChefUser"

extension ChefUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChefUser> {
        return NSFetchRequest<ChefUser>(entityName: chefUserEntityName)
    }

    class func getChefData (_ context:NSManagedObjectContext) ->  [ChefUser] {

        return DatabaseHelper.sharedInstance.getEntitiesWithName(chefUserEntityName, sortKey: nil, predicate: nil, ascending: false, context: context) as! [ChefUser]

    }


}
