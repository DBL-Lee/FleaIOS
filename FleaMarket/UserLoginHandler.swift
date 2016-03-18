//
//  UserLoginHandler.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//
import Alamofire
import SwiftyJSON
import SimpleKeychain

enum registerUserResult{
    case Success
    case duplicateEmail
    case wrongVerifyCode
    case verifyCodeExpired
    case duplicateNickname
}

class UserLoginHandler{
    static let instance = UserLoginHandler()
    
    let JWTTokenKey = "FleaMarket_JWT_token"
    
    func login(username:String,password:String,completion:Bool->Void){
        let parameter = ["email":username,"password":password]
        Alamofire.request(.POST, userLoginURL, parameters: parameter, encoding: .JSON, headers: nil).validate().responseJSON{
            response in
            switch response.result{
            case .Success:
                let json = JSON(response.result.value!)
                A0SimpleKeychain().setString(json["token"].stringValue, forKey: self.JWTTokenKey)
                NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSinceNow: NSTimeInterval(json["expiration"].intValue*60*60*24)), forKey: "TokenExpirationDate")
                completion(true)
            case .Failure:
                A0SimpleKeychain().deleteEntryForKey(self.JWTTokenKey)
                completion(false)
            }
        }
    }
    
    let tokenExpirationKey = "TokenExpirationDate"
    
    func refreshToken(){
        if let expirationDate = NSUserDefaults.standardUserDefaults().objectForKey("TokenExpirationDate"){
            if NSDate().isBefore(expirationDate as! NSDate){ // not expired
                let parameter = ["token":A0SimpleKeychain().stringForKey(JWTTokenKey)!]
                Alamofire.request(.POST, tokenRefreshURL, parameters: parameter, encoding: .JSON, headers: nil).validate().responseJSON{
                    response in
                    switch response.result{
                    case .Success:
                        let json = JSON(response.result.value!)
                        A0SimpleKeychain().setString(json["token"].stringValue, forKey: self.JWTTokenKey)
                        NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSinceNow: NSTimeInterval(json["expiration"].intValue)), forKey: self.tokenExpirationKey) //renew expiration time
                    case .Failure:
                        //should not reach here but just in case
                        A0SimpleKeychain().deleteEntryForKey(self.JWTTokenKey)
                    }
                }
            }else{
                A0SimpleKeychain().deleteEntryForKey(JWTTokenKey)
            }
        }else{
            A0SimpleKeychain().deleteEntryForKey(JWTTokenKey)
        }
    }
    
    func registerNewAccount(email:String,password:String,nickname:String,verifycode:String,verifyID:Int,completion:registerUserResult->Void){
        let parameter = ["email":email,"password":password,"nickname":nickname,"id":"\(verifyID)","code":verifycode]
        Alamofire.request(.POST, userRegisterURL, parameters: parameter, encoding: .JSON, headers: nil).responseJSON{
            response in
            switch response.result{
            case .Success:
                if response.response?.statusCode < 400{
                    completion(.Success)
                }else{
                    let error = JSON(response.result.value!)["error"].stringValue
                    switch error{
                    case "1": completion(.wrongVerifyCode)
                    case "2": completion(.verifyCodeExpired)
                    case "3": completion(.duplicateEmail)
                    case "4": completion(.duplicateNickname)
                    default:
                        break
                    }
                }
            case .Failure:
                break
            }
        }
    }
    
    func authorizationHeader()->[String:String]{
        let token:String? = A0SimpleKeychain().stringForKey(JWTTokenKey)
        if token == nil {
            return [:]
        }
        return ["Authorization": "JWT "+token!]
    }
    
    func logoutUser(){
        A0SimpleKeychain().deleteEntryForKey(JWTTokenKey)
    }
    
    func sendVerificationEmail(email:String,completion:String->Void){
        let parameter = ["email":email]
        Alamofire.request(.POST, emailconfirmURL, parameters: parameter).responseString{
            response in
            switch response.result{
            case .Success(let id):
                completion(id)
            case .Failure:
                break
            }
        }
    }
    
    func loggedIn()->Bool{
        return A0SimpleKeychain().stringForKey(JWTTokenKey) != nil
    }
}