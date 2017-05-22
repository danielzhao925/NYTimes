//
//  DatabaseManager.swift
//  NYTimes
//
//  Created by NCS-zdq on 13/5/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import UIKit
import CoreData

class DatabaseManager: NSObject {
    
    static let shareDatabaseManager = DatabaseManager()
    fileprivate let databaseServices = DatabaseServices.shareDatabaseServices
    
    fileprivate lazy var managedContext : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        return managedContext
    }()
    
    func getSearchHistoryList() -> [SearchHistory] {
        
        let searchHistories = self.databaseServices.getList(SearchHistory.self)
        return searchHistories
    }
    
    func saveSearchHistory(keyword: String){
        let searchHistory = databaseServices.getObject(SearchHistory.self)
        searchHistory.setValue(keyword, forKeyPath: #keyPath(SearchHistory.keyword))
        databaseServices.save()
    }
    
    func deleteAllSearchHistory() {
        self.databaseServices.deleteAllData(SearchHistory.self)
    }
}
