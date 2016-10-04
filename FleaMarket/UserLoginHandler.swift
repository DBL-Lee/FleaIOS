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
import CoreData

enum registerUserResult{
    case Success
    case duplicateEmail
    case wrongVerifyCode
    case verifyCodeExpired
    case duplicateNickname
}

class UserLoginHandler:NSObject,EMClientDelegate{
    static var instance = UserLoginHandler()
    
    let JWTTokenKey = "FleaMarket_JWT_token"
    
    var nickname = ""
    var avatarImageURL = ""
    var userid = 0
    
    override init() {
        super.init()
        EMClient.sharedClient().addDelegate(self, delegateQueue: nil)
        print("UserLoginHandler finished\n")
    }
    
    func login(username:String,password:String,completion:Bool->Void){
        let parameter = ["email":username,"password":password]
        Alamofire.request(.POST, userLoginURL, parameters: parameter, encoding: .JSON, headers: nil).validate().responseJSON{
            response in
            switch response.result{
            case .Success:
                let json = JSON(response.result.value!)
                A0SimpleKeychain().setString(json["token"].stringValue, forKey: self.JWTTokenKey)
                let user = json["user"]
                self.userid = user["id"].intValue
                self.nickname = user["nickname"].stringValue
                self.avatarImageURL = user["avatar"].stringValue
                
                self.EMlogin(user["EMUser"].stringValue, password: user["EMPass"].stringValue)
                
                let expiredate = NSDate(timeIntervalSinceNow: NSTimeInterval(json["expiration"].intValue))
                NSUserDefaults.standardUserDefaults().setObject(expiredate, forKey: "TokenExpirationDate")

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
                        
                        let user = json["user"]
                        self.userid = user["id"].intValue
                        self.nickname = user["nickname"].stringValue
                        self.avatarImageURL = user["avatar"].stringValue
                        
                        self.EMlogin(user["EMUser"].stringValue, password: user["EMPass"].stringValue)
                        
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
    
    func EMlogin(username:String,password:String){
        if !EMClient.sharedClient().isLoggedIn{
            let error = EMClient.sharedClient().loginWithUsername(username, password: password)
            if (error == nil){ //login success
                EMClient.sharedClient().options.isAutoLogin = true
                EMClient.sharedClient().chatManager.getAllConversations()
            }else{ //login fail
                print(error)
            }
        }
    }

    func didAutoLoginWithError(aError: EMError!) {
        if aError == nil{
            EMClient.sharedClient().chatManager.getAllConversations()
        }
    }
    
    
    func registerNewAccount(email:String,password:String,nickname:String,verifycode:String,verifyID:Int,completion:(Bool,String?)->Void){
        let parameter = ["email":email,"password":password,"nickname":nickname,"id":"\(verifyID)","code":verifycode]
        Alamofire.request(.POST, userRegisterURL, parameters: parameter, encoding: .JSON, headers: nil).responseJSON{
            response in
            switch response.result{
            case .Success:
                if response.response?.statusCode < 400{
                    completion(true,nil)
                }else{
                    let error = JSON(response.result.value!)["error"].stringValue
                    completion(false,error)
                }
            case .Failure:
                completion(false,connectionFailureString)
            }
        }
    }
    
    func getUserDetailFromCloud(userid:Int?,emusername:String?,completion:(User?,Bool)->Void){
        var parameter:[String:AnyObject] = [:]
        if userid != nil{
            parameter["userid"] = userid!
        }
        if emusername != nil{
            parameter["emusername"] = emusername!
        }
        Alamofire.request(.POST, userOverviewURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
            response in
            switch response.result{
            case .Success:
                if response.response?.statusCode<400{
                    
                    let json = JSON(response.result.value!)
                    var gender:String = ""
                    if let g = json["gender"].int{
                        gender = g == 0 ? "女" : "男"
                    }else{
                        gender = ""
                    }
                    let user = CoreDataHandler.instance.updateUserToCoreData(json["id"].intValue, emusername: json["emusername"].stringValue, nickname: json["nickname"].stringValue, avatar: json["avatar"].stringValue, transaction: json["transaction"].intValue, goodfeedback: json["goodfeedback"].intValue, posted: json["posted"].intValue, gender: gender, location: json["location"].stringValue, introduction: json["introduction"].stringValue)
                    completion(user,json["following"].boolValue)
                    
                }else{
                    completion(nil,false)
                }
            case .Failure:
                completion(nil,false)
            }
        }
    }
    
    func editDetailOfCurrentUser(avatar:String? = nil,gender:Int? = nil,location:String? = nil,introduction:String? = nil, completion:Bool->Void){
        var paramter:[String:AnyObject] = [:]
        if let avatar = avatar{
            paramter["avatar"] = avatar
        }
        if let gender = gender{
            paramter["gender"] = gender
        }
        if let location = location{
            paramter["location"] = location
        }
        if let introduction = introduction{
            paramter["introduction"] = introduction
        }
        
        Alamofire.request(.POST, userModifyURL, parameters: paramter, encoding: .JSON, headers: self.authorizationHeader()).responseData{
            response in
            switch response.result{
            case .Success:
                if response.response?.statusCode<400{
                    if let avatar = avatar{
                        self.avatarImageURL = avatar
                    }
                    completion(true)
                }else{
                    completion(false)
                }
            case .Failure(let e):
                print(e)
                completion(false)
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
    
    func logoutUser(completion:()->Void){
        A0SimpleKeychain().deleteEntryForKey(JWTTokenKey)
        EMClient.sharedClient().logout(true)
        completion()
    }
    
    
    
//    let APNSTokenKey = "APNSToken"
//    func registerAPNStoken(token:String){
//        if let existingToken = NSUserDefaults.standardUserDefaults().stringForKey(APNSTokenKey){
//            if token != existingToken{
//                saveToken(token)
//            }
//        }else{
//            saveToken(token)
//        }
//    }
//    
//    func saveToken(token:String){
//        NSUserDefaults.standardUserDefaults().setValue(token, forKey: APNSTokenKey)
//        //sync with server
//        
//    }
//    
//    func getAPNSToken()->String?{
//        return NSUserDefaults.standardUserDefaults().stringForKey(APNSTokenKey)
//    }
    
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
        return A0SimpleKeychain().stringForKey(JWTTokenKey) != nil && EMClient.sharedClient().isLoggedIn
    }
}