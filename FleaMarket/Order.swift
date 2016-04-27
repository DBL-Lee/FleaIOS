//
//  Order.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 19/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import Foundation
import SwiftyJSON

class Order{
    var id:Int!
    var product:Product!
    var buyerid:Int!
    var buyernickname:String!
    var buyeravatar:String!
    var amount:Int!
    var time_ordered:NSDate!
    var finished:Bool!
    var accepted:Bool?
    var ongoing:Bool!
    var voidedbyseller:Bool?
    var sellerfeedbacked:Bool = false
    var buyerfeedbacked:Bool = false
    
    static func deserialize(json:JSON)->Order{
        
        let id = json["id"].intValue
        let product = Product.deserialize(json["product"])
        let buyerid = json["buyerid"].intValue
        let buyernickname = json["buyernickname"].stringValue
        let buyeravatar = json["buyeravatar"].stringValue
        let amount = json["amount"].intValue
        
        
        let timestring = json["time_ordered"].stringValue
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let time_ordered = dateFormatter.dateFromString(timestring)!
        
        let finished = json["finished"].boolValue
        let accepted = json["accepted"].bool
        let ongoing = json["ongoing"].boolValue
        let buyerfeedbacked = json["buyerfeedbacked"].boolValue
        let sellerfeedbacked = json["sellerfeedbacked"].boolValue
        let voidedbyseller = json["voidedbyseller"].bool
        
        let order = Order(id: id, product: product, buyerid: buyerid, buyernickname: buyernickname, buyeravatar: buyeravatar, amount: amount, time_ordered: time_ordered, finished: finished, accepted: accepted, ongoing: ongoing, voidedbyseller: voidedbyseller,sellerfeedbacked: sellerfeedbacked, buyerfeedbacked: buyerfeedbacked)
        return order
        
    }
    
    init(id:Int,product:Product,buyerid:Int,buyernickname:String,buyeravatar:String,amount:Int,time_ordered:NSDate,finished:Bool,accepted:Bool?,ongoing:Bool,voidedbyseller:Bool?,sellerfeedbacked:Bool,buyerfeedbacked:Bool){
        self.id = id
        self.product = product
        self.buyerid = buyerid
        self.buyernickname = buyernickname
        self.buyeravatar = buyeravatar
        self.amount = amount
        self.time_ordered = time_ordered
        self.finished = finished
        self.accepted = accepted
        self.ongoing = ongoing
        self.sellerfeedbacked = sellerfeedbacked
        self.buyerfeedbacked = buyerfeedbacked
        self.voidedbyseller = voidedbyseller
    }
    
    let you = "您"
    let him = "对方"
    func sellertitle()->String{
        return isbuyer() ? him : you
    }
    func buyertitle()->String{
        return isbuyer() ? you : him
    }
    
    func isbuyer()->Bool {
        return self.buyerid == UserLoginHandler.instance.userid
    }
    
    func notfeedbacked()->Bool{
        return (isbuyer() && !buyerfeedbacked) || (!isbuyer() && !sellerfeedbacked)
    }
    
    func status()->String{
        
        if ongoing!{
            
            if accepted == nil {
                return "等待" + sellertitle() + "回复"
            }else if accepted!{
                if finished!{
                    if isbuyer(){
                        if buyerfeedbacked{
                            return "等待"+sellertitle()+"评价"
                        }else{
                            return "等待"+buyertitle()+"评价"
                        }
                    }else{
                        if sellerfeedbacked{
                            return "等待"+buyertitle()+"评价"
                        }else{
                            return "等待"+sellertitle()+"评价"
                        }
                    }
                }else{
                    return "等待" + buyertitle() + "收货"
                }
            }
        }else{
            if finished!{
                return "已完成"
            }else{
                if let accepted = accepted{
                    if !accepted{
                        return sellertitle()+"已拒绝求购"
                    }else{
                        
                    }
                }else{
                    return buyertitle()+"已取消求购"
                }
                
                if let voidedbyseller = voidedbyseller{
                    if voidedbyseller{
                        return sellertitle()+"已取消订单"
                    }else{
                        return buyertitle()+"已取消订单"
                    }
                }
                    
            }

        }
        return ""
    }
}