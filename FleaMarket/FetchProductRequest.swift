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

class FetchProductRequest{
    var title:String?
    var primarycategory:Int?
    var secondarycategory:Int?
    var minprice:String?
    var maxprice:String?
    var brandNew:Bool?
    var exchange:Bool?
    var bargain:Bool?
    
    func request(completion:(String,String,[Product])->Void){
        var url = getProductURL
        if title != nil || primarycategory != nil || secondarycategory != nil || minprice != nil || maxprice != nil || brandNew != nil || exchange != nil || bargain != nil{
            url+="?"
            if let title = title{
                url+="title="+title+"&"
            }
            if let p = primarycategory {
                url+="primarycategory=\(p)&"
            }
            if let s = secondarycategory {
                url+="secondarycategory=\(s)&"
            }
            if let min = minprice{
                url+="min_price="+min+"&"
            }
            if let max = maxprice{
                url+="max_price="+max+"&"
            }
            if let brandNew = brandNew{
                url+="brandNew=\(brandNew)&"
            }
            if let exchange = exchange{
                url+="exchange=\(exchange)&"
            }
            if let bargain = bargain{
                url+="bargain=\(bargain)&"
            }
            //remove last &
            url.removeAtIndex(url.endIndex.predecessor())
            url = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        
        
        Alamofire.request(.GET, url).responseJSON{
            response in
            switch response.result{
            case .Success:
                let json = JSON(response.result.value!)
                let previous = json["previous"].stringValue
                let next = json["next"].stringValue
                var products:[Product] = []
                for (_,productjson) in json["results"] {
                    products.append(Product.deserialize(productjson))
                }
                completion(previous,next,products)
            case .Failure(let e):
                print(e)
            }
        }
    }
}