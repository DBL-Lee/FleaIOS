//
//  CoreDataHandler.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 14/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//
import SwiftyJSON
import CoreData

class User{
    var id:Int!
    var emusername:String!
    var nickname:String!
    var avatar:String!
    var transaction:Int!
    var goodfeedback:Int!
    var posted:Int!
    var gender:String?
    var location:String?
    var introduction:String?
    
    init(id:Int,emusername:String,nickname:String,avatar:String,transaction:Int,goodfeedback:Int,posted:Int,gender:String,location:String,introduction:String){
        self.id = id
        self.emusername = emusername
        self.nickname = nickname
        self.avatar = avatar
        self.transaction = transaction
        self.goodfeedback = goodfeedback
        self.posted = posted
        self.gender = gender == "" ? nil : gender
        self.location = location == "" ? nil : location
        self.introduction = introduction == "" ? nil : introduction
    }
    
}

class CoreDataHandler{
    static var instance = CoreDataHandler()
    var appDelegate:AppDelegate!
    var managedContext:NSManagedObjectContext!
    var users:[User] = []
    
    init(){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        let fetch = NSFetchRequest()
        fetch.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: appDelegate.managedObjectContext)
        do{
            let fetchResult = try managedContext.executeFetchRequest(fetch)
            for f in fetchResult{
                let user = User(id: f.valueForKey("id") as! Int, emusername: f.valueForKey("emusername") as! String, nickname: f.valueForKey("nickname") as! String, avatar: f.valueForKey("avatar") as! String, transaction: f.valueForKey("transaction") as! Int, goodfeedback: f.valueForKey("goodfeedback") as! Int, posted: f.valueForKey("posted") as! Int, gender: f.valueForKey("gender") as! String, location: f.valueForKey("location") as! String, introduction: f.valueForKey("introduction") as! String)
                users.append(user)
            }
        }catch let error{
            print(error)
        }
    }
    
    func findUser(userid:Int?,emusername:String?)->User?{
        for user in users{
            if userid != nil{
                if user.id == userid! {
                    return user
                }
            }
            if emusername != nil{
                if user.emusername == emusername! {
                    return user
                }
            }
        }
        return nil
    }
    
    func getUserFromCoreData(userid:Int?,emusername:String?,completion:User?->Void){
        if let user = findUser(userid, emusername: emusername){
            completion(user)
        }else{
            UserLoginHandler.instance.getUserDetailFromCloud(userid, emusername: emusername){
                user in
                completion(user)
            }
        }
//        let fetchRequest = NSFetchRequest(entityName: "User")
//        var predicate:NSPredicate!
//        if userid != nil{
//            predicate = NSPredicate(format: "id=%d", userid!)
//        }
//        if emusername != nil {
//            predicate = NSPredicate(format: "emusername=%@", emusername!)
//        }
//        fetchRequest.predicate = predicate
//        do {
//            let fetchResult = try managedContext.executeFetchRequest(fetchRequest)
//            
//            if fetchResult.count>0{
//                completion(fetchResult[0] as? NSManagedObject)
//            }else{
//                UserLoginHandler.instance.getUserDetail(userid, emusername: emusername){
//                    user in
//                    completion(user)
//                }
//            }
//        }catch let error{
//            print(error)
//        }
    }
    
    func updateUserToCoreData(id:Int,emusername:String,nickname:String,avatar:String,transaction:Int,goodfeedback:Int,posted:Int,gender:String,location:String,introduction:String)->User?{
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "id=%d", id)
        fetchRequest.predicate = predicate
        do {
            let fetchResult = try managedContext.executeFetchRequest(fetchRequest)
            var user:NSManagedObject!
            if fetchResult.count>0{
                user = fetchResult[0] as! NSManagedObject
            }else{
                let userEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
                user = NSManagedObject(entity: userEntity!, insertIntoManagedObjectContext: managedContext)
            }
            user.setValue(id, forKey: "id")
            user.setValue(emusername, forKey: "emusername")
            user.setValue(nickname, forKey: "nickname")
            user.setValue(avatar, forKey: "avatar")
            user.setValue(transaction, forKey: "transaction")
            user.setValue(goodfeedback, forKey: "goodfeedback")
            user.setValue(posted, forKey: "posted")
            user.setValue(gender, forKey: "gender")
            user.setValue(location, forKey: "location")
            user.setValue(introduction, forKey: "introduction")
            do{
                try managedContext.save()
                let user = User(id: user.valueForKey("id") as! Int, emusername: user.valueForKey("emusername") as! String, nickname: user.valueForKey("nickname") as! String, avatar: user.valueForKey("avatar") as! String, transaction: user.valueForKey("transaction") as! Int, goodfeedback: user.valueForKey("goodfeedback") as! Int, posted: user.valueForKey("posted") as! Int,gender: user.valueForKey("gender") as! String,location: user.valueForKey("location") as! String,introduction: user.valueForKey("introduction") as! String)
                for i in 0..<users.count{ // remove old instance from cached data
                    if users[i].id == user.id{
                        users.removeAtIndex(i)
                        break
                    }
                }
                users.append(user)
                return user
            }catch let error{
                print(error)
            }
        }catch let error{
            print(error)
        }
        return nil
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
        if #available(iOS 9.0, *) {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedContext.executeRequest(deleteRequest)
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "SearchHistoryID")
            } catch let error as NSError {
                print(error)
            }
        } else {
            let fetch = NSFetchRequest()
            fetch.entity = NSEntityDescription.entityForName("SearchHistory", inManagedObjectContext: appDelegate.managedObjectContext)
            fetch.includesPropertyValues = false
            
            do {
                let search: NSArray = try appDelegate.managedObjectContext.executeFetchRequest(fetch)
                
                for s in search {
                    appDelegate.managedObjectContext.delete(s)
                }
                
                try appDelegate.managedObjectContext.save()
                
            } catch let error as NSError {
                print("Error occured while fetching or saving: \(error)")
            }
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
        let fetchRequest2 = NSFetchRequest(entityName: "SecondaryCategory")
        if #available(iOS 9.0, *) {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
            
            do {
                try managedContext.executeRequest(deleteRequest)
                try managedContext.executeRequest(deleteRequest2)
            } catch let error as NSError {
                print(error)
            }
        } else {
            // Fallback on earlier versions
            let fetch = NSFetchRequest()
            fetch.entity = NSEntityDescription.entityForName("PrimaryCategory", inManagedObjectContext: appDelegate.managedObjectContext)
            fetch.includesPropertyValues = false
            let fetch2 = NSFetchRequest()
            fetch2.entity = NSEntityDescription.entityForName("SecondaryCategory", inManagedObjectContext: appDelegate.managedObjectContext)
            fetch2.includesPropertyValues = false
            
            do {
                let pricat: NSArray = try appDelegate.managedObjectContext.executeFetchRequest(fetch)
                let seccat: NSArray = try appDelegate.managedObjectContext.executeFetchRequest(fetch2)
                for p in pricat {
                    appDelegate.managedObjectContext.delete(p)
                }
                for s in seccat {
                    appDelegate.managedObjectContext.delete(s)
                }
                
                try appDelegate.managedObjectContext.save()
                
            } catch let error as NSError {
                print("Error occured while fetching or saving: \(error)")
            }
        }
        
        
        //update the new categories
        let primaryEntity = NSEntityDescription.entityForName("PrimaryCategory", inManagedObjectContext: managedContext)
        let secondaryEntity = NSEntityDescription.entityForName("SecondaryCategory", inManagedObjectContext: managedContext)
        for (_,pricat):(String, JSON) in response {
            let primary = NSManagedObject(entity: primaryEntity!, insertIntoManagedObjectContext: managedContext)
            primary.setValue(pricat["id"].intValue, forKey: "id")
            primary.setValue(pricat["title"].stringValue, forKey: "title")
            primary.setValue(pricat["icon"].stringValue, forKey: "iconPath")
            primary.setValue(pricat["icon_naked"].stringValue, forKey: "nakedIconPath")
            
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