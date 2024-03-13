//
//  ChefUser+CoreDataClass.swift
//  
//
//  Created by M Abubaker Majeed on 19/04/2019.
//
//

import Foundation
import CoreData


class ChefUser: NSManagedObject, DBEntity {

    @NSManaged  var blog: String?
    @NSManaged public var id: Int64
    @NSManaged public var imageUrl: String?
    @NSManaged public var insta: String?
    @NSManaged public var name: String?

}
