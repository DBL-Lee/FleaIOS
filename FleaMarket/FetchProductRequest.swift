//
//  FetchProductRequest.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 24/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

enum FetchRequestSortType:String{
    case DEFAULT = "default"
    case distance = "distance"
    case posttime = "posttime"
    case price = "price"
    case pricedesc = "-price"
}

class FetchProductRequest:NSObject,CLLocationManagerDelegate{
    var title:String?
    var primarycategory:Int?
    var secondarycategory:Int?
    var minprice:Int?
    var maxprice:Int?
    var brandNew:Bool?
    var exchange:Bool?
    var bargain:Bool?
    var locationManager:CLLocationManager!
    var latitude:Double!
    var longitude:Double!
    var maxdistance:Int?
    
    var sortType:FetchRequestSortType = .DEFAULT
    
    override init(){
        locationManager = CLLocationManager()
        super.init()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocation = locations.first!
        latitude = locValue.coordinate.latitude
        longitude = locValue.coordinate.longitude
    }
    
    func request(completion:(String,String,[Product],Bool)->Void){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){ //run in background thread to prevent blocking UI
            var url = getProductURL
            
            url+="?"
            
    //        if title != nil || primarycategory != nil || secondarycategory != nil || minprice != nil || maxprice != nil || brandNew != nil || exchange != nil || bargain != nil{
                if let title = self.title{
                    url+="title="+title+"&"
                }
                if let p = self.primarycategory {
                    url+="primarycategory=\(p)&"
                }
                if let s = self.secondarycategory {
                    url+="secondarycategory=\(s)&"
                }
                if let min = self.minprice{
                    url+="min_price="+"\(min)&"
                }
                if let max = self.maxprice{
                    url+="max_price="+"\(max)&"
                }
                if let brandNew = self.brandNew{
                    url+="brandNew="+(brandNew ? "True" : "False" )+"&"
                }
                if let exchange = self.exchange{
                    url+="exchange="+(exchange ? "True" : "False" )+"&"
                }
                if let bargain = self.bargain{
                    url+="bargain="+(bargain ? "True" : "False" )+"&"
                }
                if let distance = self.maxdistance{
                    url+="distance=\(distance)&"
                }
                
                url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    //        }
            
            let rl = NSRunLoop.currentRunLoop()
            while(self.longitude==nil||self.latitude==nil){
                print("waiting")
            }
            url+="latitude=\(self.latitude)&longitude=\(self.longitude)&"
            
            url+="sorttype="+self.sortType.rawValue
            
            Alamofire.request(.GET, url).responseJSON{
                response in
                switch response.result{
                case .Success:
                    if response.response?.statusCode < 400{
                        let json = JSON(response.result.value!)
                        let previous = json["previous"].stringValue
                        let next = json["next"].stringValue
                        var products:[Product] = []
                        for (_,productjson) in json["results"] {
                            products.append(Product.deserialize(productjson))
                        }
                        dispatch_async(dispatch_get_main_queue()){
                            completion(previous,next,products,true)
                        }
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue()){
                            completion("","",[],false)
                        }
                    }
                case .Failure(let e):
                    
                    dispatch_async(dispatch_get_main_queue()){
                        completion("","",[],false)
                    }
                }
            }
        }
    }
}