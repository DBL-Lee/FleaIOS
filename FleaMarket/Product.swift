//
//  Product.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 23/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SwiftyJSON

class Product{
    var id:Int!
    
    var userid:Int!
    var usernickname:String!
    var useravatar:String!
    
    var locale:NSLocale!
    var imageUUID:[String]!
    var thumbnailUUID:[String]!
    var title:String!
    var currentPrice:String!
    var mainCategory:String!
    var secondaryCategory:String!
    var location:CLPlacemark!
    
    var soldAmount:Int!
    var amount:Int!
    var city:String!
    var country:String!
    var mainimage:Int!
    var latitude:Double!
    var longitude:Double!
    
    var postedTime:NSDate!
    
    var originalPrice:String?
    var brandNew:Bool?
    var bargain:Bool?
    var exchange:Bool?
    
    var description:String?
    
    static func deserialize(json:JSON)->Product{
        let id = json["id"].intValue
        let title = json["title"].stringValue
        let currentPrice = json["price"].stringValue
        var images:[String] = []
        for (_,image) in json["images"]{
            images.append(image["uuid"].stringValue)
        }
        let mainimage = json["mainimage"].intValue
        let categoryID = json["category"].intValue
        let countryISO = json["location"].stringValue
        let components = [NSLocaleCountryCode : countryISO]
        let localeIdentifier = NSLocale.localeIdentifierFromComponents(components)
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        
        let latitude = json["latitude"].doubleValue
        let longitude = json["longitude"].doubleValue
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let city = json["city"].stringValue
        let country = json["country"].stringValue
        
        var placemark:CLPlacemark!
        
        let soldAmount = json["soldAmount"].intValue
        let amount = json["amount"].intValue
        let timestring = json["postedTime"].stringValue
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(timestring)!
        
        let userid = json["userid"].intValue
        let usernickname = json["usernickname"].stringValue
        let useravatar = json["useravatar"].stringValue
        
        let product = Product(id: id, images: images, title: title,mainimage: mainimage, currentPrice: currentPrice, categoryID: categoryID, city: city, country: country,soldAmount: soldAmount, amount: amount, postedTime: date, originalPrice: json["originalPrice"].string, brandNew: json["brandNew"].bool, bargain: json["bargain"].bool, exchange: json["exchange"].bool, description: json["description"].string,locale:locale,latitude:latitude,longitude:longitude,userid: userid, usernickname: usernickname, useravatar:useravatar)
        
//        CLGeocoder().reverseGeocodeLocation(location){(placemarks, error) -> Void in
//            if error != nil {
//                print("Reverse geocoder failed with error" + error!.localizedDescription)
//                return
//            }
//            if placemarks!.count > 0 {
//                placemark = placemarks![0]
//                product.location = placemark
//            }
//        }
        
        return product
    }
    
    init(id:Int,images:[String],title:String,mainimage:Int,currentPrice:String,categoryID:Int,city:String,country:String,soldAmount:Int,amount:Int,postedTime:NSDate,originalPrice:String?, brandNew:Bool?, bargain:Bool?, exchange:Bool?, description:String?,locale:NSLocale,latitude:Double,longitude:Double,userid:Int,usernickname:String,useravatar:String){
        self.id = id
        self.imageUUID = images
        self.title = title
        self.currentPrice = currentPrice
        self.mainimage = mainimage
        
        self.userid = userid
        self.usernickname = usernickname
        self.useravatar = useravatar
        
        self.city = city
        self.country = country
        
        
        self.soldAmount = soldAmount
        self.amount = amount
        self.postedTime = postedTime
        
        self.originalPrice = originalPrice
        self.brandNew = brandNew
        self.bargain = bargain
        self.exchange = exchange
        self.description = description
        
        self.locale = locale
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getCity()->String{
        if location == nil{
            return city
        }
        if location.locality != nil {
            return location.locality!
        }
        return location.name!
    }
    
    func getCountry()->String{
        if location == nil{
            return country
        }
        return location.country!
    }
    
    func getLocation()->String{
        return getCity()+", "+getCountry()
    }
    
    func getCurrentPriceWithCurrency()->String{
        return currentPrice.toCurrencyInLocale(locale)
    }
    
    func getOriginalPriceWithCurrency()->String{
        if originalPrice == nil {return ""}
        return originalPrice!.toCurrencyInLocale(locale)
    }
}