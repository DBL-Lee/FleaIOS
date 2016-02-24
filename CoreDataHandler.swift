//
//  CoreDataHandler.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 14/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//
import SwiftyJSON
import CoreData

class CoreDataHandler{
    static let instance = CoreDataHandler()
    var appDelegate:AppDelegate!
    var managedContext:NSManagedObjectContext!
    
    init(){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
    }
    
    func addSearchHistoryToCoreData(string:String){
        //check if already exists
        let fetchRequest = NSFetchRequest(entityName: "SearchHistory")
        let predicate = NSPredicate(format: "title=%@", string)
        fetchRequest.predicate = predicate
        do {
            let fetchResult = try managedContext.executeFetchRequest(fetchRequest)
            if fetchResult.count>0{
                let object = fetchResult[0] as! NSManagedObject
                let id = NSUserDefaults.standardUserDefaults().integerForKey("SearchHistoryID")
                object.setValue(id, forKey: "id")
                do{
                    try managedContext.save()
                    NSUserDefaults.standardUserDefaults().setInteger(id+1, forKey: "SearchHistoryID")
                }catch let error{
                    print(error)
                }
            }else{
                let historyEntity = NSEntityDescription.entityForName("SearchHistory", inManagedObjectContext: managedContext)
                let history = NSManagedObject(entity: historyEntity!, insertIntoManagedObjectContext: managedContext)
                history.setValue(string, forKey: "title")
                let id = NSUserDefaults.standardUserDefaults().integerForKey("SearchHistoryID")
                history.setValue(id,forKey:"id")
                
                do{
                    try managedContext.save()
                    NSUserDefaults.standardUserDefaults().setInteger(id+1, forKey: "SearchHistoryID")
                }catch let error{
                    print(error)
                }
            }
        }catch let error{
            print(error)
        }
        
        
        
    }
    
    func clearSearchHistory(){
        let fetchRequest = NSFetchRequest(entityName: "SearchHistory")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.executeRequest(deleteRequest)
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "SearchHistoryID")
        } catch let error as NSError {
            print(error)
        }
    }
    
    func getSearchHistory()->[String]{
        let fetchRequest = NSFetchRequest(entityName: "SearchHistory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        do {
            let history = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            return history.map({
                object in
                return object.valueForKey("title") as! String
            })
            
        }catch let error as NSError{
            print(error)
        }
        return []
    }
    
    func updateCategoryToCoreData(response:JSON){
        //delete currently stored categories
        let fetchRequest = NSFetchRequest(entityName: "PrimaryCategory")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let fetchRequest2 = NSFetchRequest(entityName: "SecondaryCategory")
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        
        do {
            try managedContext.executeRequest(deleteRequest)
            try managedContext.executeRequest(deleteRequest2)
        } catch let error as NSError {
            print(error)
        }
        
        //update the new categories
        let primaryEntity = NSEntityDescription.entityForName("PrimaryCategory", inManagedObjectContext: managedContext)
        let secondaryEntity = NSEntityDescription.entityForName("SecondaryCategory", inManagedObjectContext: managedContext)
        for (_,pricat):(String, JSON) in response {
            let primary = NSManagedObject(entity: primaryEntity!, insertIntoManagedObjectContext: managedContext)
            primary.setValue(pricat["id"].intValue, forKey: "id")
            primary.setValue(pricat["title"].stringValue, forKey: "title")
            print(pricat["title"].stringValue)
            let secondaries = pricat["secondary"]
            for (_,seccat):(String,JSON) in secondaries{
                let secondary = NSManagedObject(entity: secondaryEntity!, insertIntoManagedObjectContext: managedContext)
                secondary.setValue(seccat["id"].intValue, forKey: "id")
                secondary.setValue(seccat["title"].stringValue, forKey: "title")
                secondary.setValue(primary, forKey: "primary")
                print("   "+seccat["title"].stringValue)
            }
        }
        
        do{
            try managedContext.save()
        }catch let error{
            print(error)
        }
    }
    
    func getPrimaryCategoryList()->[NSManagedObject]{
        let fetchRequest = NSFetchRequest(entityName: "PrimaryCategory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            let primary = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            return primary
            
        }catch let error as NSError{
            print(error)
        }
        return []
    }
    
    func getSecondaryCategoryList(primary:NSManagedObject)->[NSManagedObject]{
        let secondarySet = primary.mutableSetValueForKey("secondary")
        let descriptor = NSSortDescriptor(key: "id", ascending: true)
        return secondarySet.sortedArrayUsingDescriptors([descriptor]) as! [NSManagedObject]
    }
    
}