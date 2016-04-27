//
//  AppDelegate.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import CoreData
import AWSCore
import AWSS3
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,EMChatManagerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //AWSLogger.defaultLogger().logLevel = .Verbose
        let image = UIImage(named: "backButton.png")!.thumbnailOfSize(CGSize(width: 40, height: 40)).imageWithRenderingMode(.AlwaysTemplate)
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(image, forState: .Normal, barMetrics: .Default)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000,vertical: -1000), forBarMetrics: .Default)
        
        let appkey = "fleamarket#fleamarket"
        let certname = "FleaMarket"
        let options = EMOptions(appkey: appkey)
        options.apnsCertName = certname
        
        EMClient.sharedClient().initializeSDKWithOptions(options)
        
        EMClient.sharedClient().chatManager.addDelegate(EaseDataHandler.shared, delegateQueue: nil)
        
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: CognitoRegionType, identityPoolId: CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region:DefaultServiceRegionType, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        //create upload and download directories
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(
                LocalUploadDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error as NSError {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(
                LocalDownloadDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error as NSError {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(
                LocalIconDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error as NSError {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
        //remove saved imagesuuid from last session
        if let res = NSUserDefaults.standardUserDefaults().objectForKey("GLOBAL_imagesUUID")  {
            let imagesUUID = res as! [String]
            let remove = AWSS3Remove()
            var objectids = [AWSS3ObjectIdentifier]()
            for uuid in imagesUUID{
                let object = AWSS3ObjectIdentifier()
                object.key = uuid
                objectids.append(object)
            }
            remove.objects = objectids
            
            let deleteRequest = AWSS3DeleteObjectsRequest()
            deleteRequest.bucket = S3ImagesBucketName
            deleteRequest.remove = remove
            
            AWSS3.defaultS3().deleteObjects(deleteRequest)
        }
        
        //Try refreshing jwt token
        if UserLoginHandler.instance.loggedIn(){
            UserLoginHandler.instance.refreshToken()
        }
       
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        EMClient.sharedClient().bindDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        EMClient.sharedClient().applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        EMClient.sharedClient().applicationWillEnterForeground(application)
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        NSUserDefaults.standardUserDefaults().setObject(GLOBAL_imagesUUID, forKey: "GLOBAL_imagesUUID")
        
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hzc.FleaMarket" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("FleaMarket", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

