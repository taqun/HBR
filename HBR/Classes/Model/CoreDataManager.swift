//
//  CoreDataManager.swift
//  HBR
//
//  Created by taqun on 2015/07/18.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
   
    static var sharedInstance: CoreDataManager = CoreDataManager()
    
    
    /*
     * Public Method
     */
    func createChannel() -> (Channel) {
        let context = self.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Channel", inManagedObjectContext: context)!
        
        let channel = Channel(entity: entity, insertIntoManagedObjectContext: context)
        
        return channel
    }
    
    func createMyBookmarksChannel() -> (MyBookmarks) {
        let context = self.managedObjectContext!
        let entity = NSEntityDescription.entityForName("MyBookmarks", inManagedObjectContext: context)!
        
        let myBookmarks = MyBookmarks(entity: entity, insertIntoManagedObjectContext: context)
        myBookmarks.type = .Mine
        
        return myBookmarks
    }
    
    func createItem() -> (Item) {
        let context = self.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: context)!
        
        let item = Item(entity: entity, insertIntoManagedObjectContext: context)
        
        return item
    }
    
    func createItemInContext(localContext: NSManagedObjectContext) -> (Item) {
        let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: localContext)!
        
        let item = Item(entity: entity, insertIntoManagedObjectContext: localContext)
        
        return item
    }
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func saveWithBlock(block: ((localContext: NSManagedObjectContext) -> (Void))) {
        
    }
    
    func saveWithBlock(block: ((localContext: NSManagedObjectContext) -> (Void)), completion: ((success: Bool, error: NSError?) -> Void)) {
        
    }
    
    
    func getEntityByName(name: String, context: NSManagedObjectContext) -> (NSEntityDescription?) {
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)
        return entity
    }
    
    
    /*
     * CoreData Stack
     */
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    var managedObjectContext: NSManagedObjectContext?
    
    func setUpCoreDataStack() {
        var coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("HBR.sqlite")
        
        var error: NSError? = nil
        
        if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            NSLog("Create persistent store error \(error)")
            abort()
        }
        
        self.persistentStoreCoordinator = coordinator
        
        self.managedObjectContext = NSManagedObjectContext()
        self.managedObjectContext?.persistentStoreCoordinator = self.persistentStoreCoordinator
    }
    
    func setUpInMemoryCoreDataStack() {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        var error: NSError? = nil
        
        if coordinator?.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error) == nil {
            NSLog("Create persistent store error \(error)")
            abort()
        }
        
        self.persistentStoreCoordinator = coordinator
        
        self.managedObjectContext = NSManagedObjectContext()
        self.managedObjectContext?.persistentStoreCoordinator = self.persistentStoreCoordinator
    }
    
    func cleanUp() {
        self.managedObjectContext = nil
        
        self.persistentStoreCoordinator = nil
    }
    
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("HBR", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let environment = NSProcessInfo.processInfo().environment as! [String : AnyObject]
        let isTest = (environment["XCInjectBundle"] as? String)?.pathExtension == "xctest"
        
        let moduleName = (isTest) ? "HBRTests" : "HBR"
        
        var newEntities = [] as [NSEntityDescription]
        for (_, entity) in enumerate(managedObjectModel.entities) {
            let newEntity = entity.copy() as! NSEntityDescription
            newEntity.managedObjectClassName = "\(moduleName).\(entity.name)"
            newEntities.append(newEntity)
        }
        
        for entity:NSEntityDescription in newEntities as [NSEntityDescription] {
            let parent:NSEntityDescription = entity
            var newSubentities = [] as [NSEntityDescription]
            
            if let subEntities = parent.subentitiesByName {
                for (entityName, entity) in subEntities {
                    for currentEntity in newEntities {
                        if entityName == currentEntity.name {
                            newSubentities.append(currentEntity)
                        }
                    }
                }
                parent.subentities = newSubentities
            }
        }
        
        let newManagedObjectModel = NSManagedObjectModel()
        newManagedObjectModel.entities = newEntities
        
        return newManagedObjectModel
    }()
    
}
