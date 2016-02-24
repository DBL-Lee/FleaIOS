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
    
    var locale:NSLocale!
    var imageUUID:[String]!
    var thumbnailUUID:[String]!
    var title:String!
    var currentPrice:String!
    var mainCategory:String!
    var secondaryCategory:String!
    var location:CLPlacemark!
    var amount:Int!
    var city:String!
    var country:String!
    var mainimage:Int!
    
    var postedTime:NSDate!
    
    var originalPrice:String?
    var brandNew:Bool?
    var bargain:Bool?
    var exchange:Bool?
    
    var description:String?
    
    static func deserialize(json:JSON)->Product{
        print(json)
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
        
        let coor = json["gps"].stringValue
        let split = coor.characters.split(" ")
        let latitude = Double(String(split[0]))!
        let longitude =  Double(String(split[1]))!
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let city = json["city"].stringValue
        let country = json["country"].stringValue
        
        var placemark:CLPlacemark!
        
        let amount = json["amount"].intValue
        let timestring = json["postedTime"].stringValue
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(timestring)!
        let product = Product(id: id, images: images, title: title,mainimage: mainimage, currentPrice: currentPrice, categoryID: categoryID, city: city, country: country, amount: amount, postedTime: date, originalPrice: json["originalPrice"].string, brandNew: json["brandNew"].bool, bargain: json["bargain"].bool, exchange: json["exchange"].bool, description: json["description"].string,locale:locale)
        
        CLGeocoder().reverseGeocodeLocation(location){(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks!.count > 0 {
                placemark = placemarks![0]
                product.location = placemark
            }
        }
        
        return product
    }
    
    init(id:Int,images:[String],title:String,mainimage:Int,currentPrice:String,categoryID:Int,city:String,country:String,amount:Int,postedTime:NSDate,originalPrice:String?, brandNew:Bool?, bargain:Bool?, exchange:Bool?, description:String?,locale:NSLocale){
        self.id = id
        self.imageUUID = images
        self.title = title
        self.currentPrice = currentPrice
        self.mainimage = mainimage
        
        self.city = city
        self.country = country
        
        self.amount = amount
        self.postedTime = postedTime
        
        self.originalPrice = originalPrice
        self.brandNew = brandNew
        self.bargain = bargain
        self.exchange = exchange
        self.description = description
        
        self.locale = locale
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