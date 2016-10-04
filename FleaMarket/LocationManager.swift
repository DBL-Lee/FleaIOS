//
//  LocationManager.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 28/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import Foundation
import CoreLocation
class LocationManager:NSObject,CLLocationManagerDelegate{
    static let instance = LocationManager()
    
    var latitude:Double! = 51.5133
    var longitude:Double! = -0.1585
    var city:String! = ""
    let CityDefaultName = "CityDefaultName"
    
    var locationManager:CLLocationManager!
    override init(){
        super.init()
        if let city = NSUserDefaults.standardUserDefaults().stringForKey(CityDefaultName){
            self.city = city
        }
        
        locationManager = CLLocationManager()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        print("LocationHandler finished\n")

    }
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocation = locations.first!
        latitude = locValue.coordinate.latitude
        longitude = locValue.coordinate.longitude
        
        CLGeocoder().reverseGeocodeLocation(locValue){
            (placemarks,error) in
            if placemarks == nil{
                
            }else{
                let placemark = placemarks![0]
                let newcity = placemark.locality == nil ? placemark.name! : placemark.locality!
                
                //post coordinate change notification
                var userinfo:[NSObject:AnyObject] = [:]
                userinfo["longitude"] = self.longitude
                userinfo["latitude"] = self.latitude
                userinfo["name"] = newcity
                let notification = NSNotification(name: LocationChangeNotificationName, object: nil, userInfo: userinfo)
                NSNotificationCenter.defaultCenter().postNotification(notification)
                
                if self.city != newcity {
                    self.city = newcity
                    //post city change notification
                    var userinfo:[NSObject:AnyObject] = [:]
                    userinfo["longitude"] = self.longitude
                    userinfo["latitude"] = self.latitude
                    userinfo["name"] = newcity
                    let notification = NSNotification(name: CityChangeNotificationName, object: nil, userInfo: userinfo)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                }
            }
        }
    }
}