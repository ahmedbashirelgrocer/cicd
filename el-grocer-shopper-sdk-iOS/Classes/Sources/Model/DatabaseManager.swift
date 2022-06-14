//
//  DatabaseManager.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
// /Users/abm/Library/Developer/CoreSimulator/Devices/DFFB1EFE-54DD-4692-BE58-50A4BDC327B2/data/Containers/Data/Application/465BFCBE-5444-4280-BF73-3C84192786B6/Documents/ElGrocer.sqlite

import Foundation
import UIKit
import CoreData

class DatabaseManager : NSObject {
    
    //Properties
    
    var persistentStoreItems: [PersistentStoreCoreDataItem]?
    
    //MARK: Persistent Store Coordinator
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =  {
        
        
        objc_sync_enter(self)
        
        let coordinator:NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        if let persistantStores = self.persistentStoreItems {
            
            for store in persistantStores {
                
                var filename = store.fileName
                
                var url = "\(filename).sqlite"
                
                var path:URL = FileManager.default.urls(for: store.searchPathDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
                let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
            
                
                var storeURL = path.appendingPathComponent(url)
                
                if let config = store.configuration {
                    
                    do {
                        
                        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: config, at: storeURL, options: options)
                        
                    } catch let error as NSError {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                        //At this point app is seriously broken and should not work properly, stop execution
                        fatalError()
                    }
                    
                }
                else {
                    
                    do {
                        
                        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
                        
                    } catch let error as NSError {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                        //At this point app is seriously broken and should not work properly, stop execution
                        print("Error:%@",error.localizedDescription)
                        fatalError()
                    }
                }
                
            }
        }
        
        objc_sync_exit(self)
        
        return coordinator
        }()
    
    // MARK: Managed Object Model
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        [unowned self] in
        
        var managedObjectModel: NSManagedObjectModel!
        
        if let persistantStores = self.persistentStoreItems {
            
            var models: [NSManagedObjectModel] = [NSManagedObjectModel]()
            
            for store in persistantStores {
                if let modelUrl = Bundle.main.url(forResource: store.model, withExtension:"momd") {
                    if let model = NSManagedObjectModel(contentsOf: modelUrl) {
                        models.append(model)
                    }
                }
            }
            
            if models.count > 1 {
                managedObjectModel = NSManagedObjectModel(byMerging: models)
            } else {
                managedObjectModel = models[0];
            }
        }
        
        return managedObjectModel
        
        }()
    
    // MARK: Managed Object Contexts
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        
        let mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        mainContext.parent = self.saveObjectContext
        return mainContext
        }()
    
    lazy var groceryManagedObjectContext: NSManagedObjectContext = {
        
        let mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        mainContext.parent = self.saveObjectContext
        return mainContext
        
    }()
    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        backgroundContext.parent = self.mainManagedObjectContext
        
        return backgroundContext
        
        }()
    
    fileprivate lazy var saveObjectContext: NSManagedObjectContext = {
        
        let saveObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        saveObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return saveObjectContext
        
        }()
    
    // MARK: Init
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DatabaseManager.contextHasChangedNotification(_:)), name:  NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Merge context
    
    @objc func contextHasChangedNotification(_ notification: Notification) {
        
        let context = notification.object as! NSManagedObjectContext
        guard context.persistentStoreCoordinator == self.persistentStoreCoordinator else {
                 return
        }
        context.mergeChanges(fromContextDidSave: notification)
        return
        /*
         
         NSManagedObjectContext * context = notification.object;
         if (context != self.managedObjectContextForMainThread) {
         if (context.persistentStoreCoordinator == self.persistentStoreCoordinator) {
         [context mergeChangesFromContextDidSaveNotification:notification];
         }
         }
         
         
         */
        
        /*
        if (context != self.mainManagedObjectContext) {
            if (context.persistentStoreCoordinator == self.persistentStoreCoordinator) {
                context.mergeChanges(fromContextDidSave: notification)
            }
        } else if context == self.mainManagedObjectContext {
            
            self.backgroundManagedObjectContext.mergeChanges(fromContextDidSave: notification)
           
        } else if context == self.backgroundManagedObjectContext {
            
            self.mainManagedObjectContext.mergeChanges(fromContextDidSave: notification)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MainManagedObjectContextMergedChangesFromBackground"), object: nil)
            //self.saveObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            
        } else if context == self.saveObjectContext {
            
            //self.backgroundManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            //self.mainManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
        }
         */
    }
    
    // MARK: Methods
    
    func saveDatabase() {
        
        self.mainManagedObjectContext.performAndWait({ () -> Void in
            
            do {
                try self.mainManagedObjectContext.save()
            } catch let error as NSError {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                print("Error: \(error.localizedDescription)")
                
            } catch {
                fatalError()
            }
            
            self.saveObjectContext.performAndWait({ () -> Void in
                
                do {
                    try self.saveObjectContext.save()
                    
                } catch let error as NSError {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                    print("Error: \(error.localizedDescription)")

                } catch {
                    fatalError()
                }
            })
        })
    }
    
    // MARK: Insert
    
    func insertNewObjectForEntityForName(_ entityName:String, entityDbId:AnyObject, keyId:String, context:NSManagedObjectContext) -> AnyObject {
        
        var object:AnyObject!
        
        context.performAndWait { () -> Void in
            
            object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            object.setValue(entityDbId, forKey: keyId)
        }
        
        return object
    }
    
    @discardableResult func insertOrReplaceObjectForEntityForName(_ entityName:String, entityDbId:AnyObject, keyId:String, context:NSManagedObjectContext) -> AnyObject {
        
        
        var object:AnyObject!
        
        context.performAndWait {[weak self]() -> Void in
            guard let self = self else {return}
            
            object = self.getEntityWithName(entityName, entityDbId: entityDbId, keyId: keyId, context: context)
            
            
            
            if self.isNotNull(object: object) == false {
                object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
                object.setValue(entityDbId, forKey: keyId)
                if entityName == ProductEntity {
                    debugPrint("Test-Product NewAddIndb : \(entityDbId)")
                }
            } else {
                if entityName == ProductEntity {
                    debugPrint("Test-Product AlreadyIndb : \(entityDbId)")
                }
            }
        }
        
        return object
    }
    
    
    
    // MARK: Get
    
    func getEntityWithName(_ entityName:String, entityDbId:AnyObject, keyId:String, context:NSManagedObjectContext) -> AnyObject? {
        
        var object:AnyObject? = nil
        
        context.performAndWait { [weak self]() -> Void in
            guard self != nil else {return}
            
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
            let predicate = NSPredicate(format: "%K == %@", keyId, entityDbId as! NSObject)
            request.predicate = predicate
            
            let objectsArray = try? context.fetch(request)
            object = objectsArray?.last as AnyObject
        }
        
        return object
    }
    
    // MARK: Get array
    
    
    func getEntitiesWithName(_ entityName:String, sortOneKey:String? , boolKey : String? , boolKeyOrderAscending : Bool, predicate: NSPredicate?, ascending:Bool, context:NSManagedObjectContext , _ fetchLimit : Int? = nil) -> [NSManagedObject] {
        
        var results:[NSManagedObject] = [NSManagedObject]()
        
        context.performAndWait { () -> Void in
            
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
            
            if let fetchPredicate = predicate {
                request.predicate = fetchPredicate
            }
            
            var sortDescriptors  : [NSSortDescriptor] = []
            
            if let key = boolKey {
                let sortDescriptor = NSSortDescriptor(key: key, ascending: boolKeyOrderAscending )
                sortDescriptors.append(sortDescriptor)
            }
            if let key = sortOneKey {
              
                
                if key == "start_time" {
                    let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending, selector: #selector(NSDate.compare(_:)))
                    sortDescriptors.append(sortDescriptor)
                }else{
                    let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
                    sortDescriptors.append(sortDescriptor)
                }
                
              
            }
            request.sortDescriptors = sortDescriptors
            if let limit = fetchLimit {
                request.fetchLimit = limit
            }
            
            do {
                results = (try context.fetch(request)) as! [NSManagedObject]
            } catch (let error) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                debugPrint("%@",error.localizedDescription)
            }
        }
        
        return results
    }
    
    
    
    func getEntitiesWithName(_ entityName:String, sortKey:String?, predicate: NSPredicate?, ascending:Bool, context:NSManagedObjectContext) -> [NSManagedObject] {
        
        var results:[NSManagedObject] = [NSManagedObject]()
        
      //  context.performAndWait { () -> Void in
            
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
            request.returnsObjectsAsFaults = false
            if let fetchPredicate = predicate {
                request.predicate = fetchPredicate
            }
            if let key = sortKey {
                
                let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
                request.sortDescriptors = [sortDescriptor];
            }
            do {
               results = (try context.fetch(request)) as! [NSManagedObject]
            } catch (let error) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                debugPrint("%@",error.localizedDescription)
            }
        //}

        return results
    }
    
    func getEntitiesWithName(_ entityName:String, sortKey:String?, predicate: NSPredicate?, ascending:Bool, caseInsensitiveCompare:Bool, context:NSManagedObjectContext) -> [NSManagedObject] {
        
        var results:[NSManagedObject] = [NSManagedObject]()
        
        context.performAndWait { () -> Void in
            
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
            
            if let fetchPredicate = predicate {
                request.predicate = fetchPredicate
            }
            
            if let key = sortKey {
                
                let sortDescriptor = caseInsensitiveCompare ? NSSortDescriptor(key: key, ascending: ascending, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))) : NSSortDescriptor(key: key, ascending: ascending)
                request.sortDescriptors = [sortDescriptor];
            }
            do {
                results = (try context.fetch(request)) as! [NSManagedObject]
            } catch (let error) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                debugPrint("%@",error.localizedDescription)
            }
            
           
        }
        
        return results
    }
    
    // MARK: - Helper Methods

    func isNotNull(object:AnyObject?) -> Bool {
        guard let object = object else {
            return false
        }
        return (isNotNSNull(object: object) && isNotStringNull(object: object))
    }
    
    func isNotNSNull(object:AnyObject) -> Bool {
        return object.classForCoder != NSNull.classForCoder()
    }
    
    func isNotStringNull(object:AnyObject) -> Bool {
        if let object = object as? String, object.uppercased() == "NULL" {
            return false
        }
        return true
    }
    
}

// MARK: PersistentStoreItem

class PersistentStoreCoreDataItem {
    
    var model: String
    var configuration: String?
    var searchPathDirectory: FileManager.SearchPathDirectory
    
    var fileName: String {
        
        if let config = self.configuration {
            
            return "\(self.model)_\(config)"
        }
        else {
            return self.model
        }
    }
    
    init(name:String) {
        
        self.model = name
        self.searchPathDirectory = .documentDirectory
    }
    
    init(name:String, configuration:String) {
        
        self.model = name
        self.configuration = configuration
        self.searchPathDirectory = .documentDirectory
    }
    
    init(name:String, configuration:String, searchPathDirectory:FileManager.SearchPathDirectory) {
        
        self.model = name
        self.configuration = configuration
        self.searchPathDirectory = searchPathDirectory
    }
}
