//
//  DatabaseServices.swift
//  NYTimes
//
//  Created by NCS-zdq on 13/5/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import UIKit
import CoreData

class DatabaseServices: NSObject {

    static let shareDatabaseServices = DatabaseServices()
    
    fileprivate lazy var managedContext : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        return managedContext
    }()
    
    func getObject<T>(_ type: T.Type) -> T where T : NSManagedObject {
    
        let entity = NSEntityDescription.entity(forEntityName: String(describing: type), in: managedContext)!
        let object = T(entity: entity, insertInto: managedContext)
        return object
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func getList<T>(_ type: T.Type) -> [T] where T : NSManagedObject {
        
        var list : [T]
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: type))
        do {
            list = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            list = [T]()
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return list
    }
}
