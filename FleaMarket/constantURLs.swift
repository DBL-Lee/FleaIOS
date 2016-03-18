//
//  constantURLs.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 11/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import Foundation

let serverLocation = "http://192.168.1.164:8000/"

let getProductURL = serverLocation+"products/"
let getCategoryURL = serverLocation+"products/primarycategory/"
let getCategoryVersionURL = getCategoryURL+"version/"

let userLoginURL = serverLocation+"api-token-auth/"
let tokenRefreshURL = serverLocation+"api-token-refresh/"
let emailconfirmURL = serverLocation+"user/email/"
let userRegisterURL = serverLocation+"user/register/"
let userselfInfoURL = serverLocation+"user/self/overview/"

let userPostedURL = serverLocation+"user/self/posted/"
let userSoldURL = serverLocation+"user/self/sold/"
let userBoughtURL = serverLocation+"user/self/bought/"