//
//  SSCoreDataController.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SSCoreDataController: NSObject {
    
    enum ManagedObjectContext {
        case managedObjectContext
        case backgroundContext
    }
    
    let store: SSCoreDataStore!
    
    
    override init(){
        // all CoreDataHelper share one CoreDataStore defined in AppDelegate
        self.store = SSCoreDataStore.sharedInstance
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSaveContext:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    
    class var sharedInstance: SSCoreDataController {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SSCoreDataController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SSCoreDataController()
        }
        return Static.instance!
    }
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // #pragma mark - Core Data stack
    
    // Returns the managed object context for the application.
    // main thread context
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.store.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    
    // Returns the background object context for the application.
    // You can use it to process bulk data update in background.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    
    lazy var backgroundContext: NSManagedObjectContext? = {
        let coordinator = self.store.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinator
        return backgroundContext
        }()
    
    
    // save NSManagedObjectContext
    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                
            } catch let error as NSError {
                // Replace this implementation with code to handle the error appropriately.
                NSLog("Unresolved error \(error), \(error.userInfo)")
//                abort()
            }
        }
    }
    
    
    func saveContext() {
        self.saveContext(self.backgroundContext!)
    }
    
    
    // call back function by saveContext, support multi-thread
    func contextDidSaveContext(notification: NSNotification) {
        let sender = notification.object as! NSManagedObjectContext
        
        if sender === self.managedObjectContext {
            NSLog("Saved main Context")
            self.backgroundContext!.performBlock {
                self.backgroundContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
        } else if sender === self.backgroundContext {
            NSLog("Saved background Context")
            self.managedObjectContext!.performBlock {
                self.managedObjectContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
        else {
            NSLog("Saved Context in other thread")
            self.backgroundContext!.performBlock {
                self.backgroundContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
            self.managedObjectContext!.performBlock {
                self.managedObjectContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
    }
    
    
    /**
    Delete all the entity of the passed name
    */
    func deleteAllObjectsForEntity(entity: NSEntityDescription, error: NSErrorPointer) {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 50
        
        let fetchResults: [AnyObject]?
        do {
            fetchResults = try managedObjectContext!.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            fetchResults = nil
        }
        if error != nil {
            return
        }
        
        if let managedObjects = fetchResults as? [NSManagedObject] {
            for object in managedObjects {
                managedObjectContext!.deleteObject(object)
            }
        }
    }
    
    
    func deleteAllItemModels() {
        let productEntity = NSEntityDescription()
        productEntity.name = "SSItemModel"
        
        deleteAllObjectsForEntity(productEntity, error: nil)
    }
    
    
    func addItem(itemDict: Dictionary<String, AnyObject>, forIndex orderIndex: Int) {
        let item = NSEntityDescription.insertNewObjectForEntityForName("SSItemModel", inManagedObjectContext: self.backgroundContext!) as? SSItemModel
        
        item?.addItem(itemDict, forIndex: orderIndex)
    }
}
