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
let buyProductURL = serverLocation+"products/buy/"

let getCategoryURL = serverLocation+"products/primarycategory/"
let getCategoryVersionURL = getCategoryURL+"version/"

let userLoginURL = serverLocation+"api-token-auth/"
let tokenRefreshURL = serverLocation+"api-token-refresh/"
let emailconfirmURL = serverLocation+"user/email/"
let userRegisterURL = serverLocation+"user/register/"
let userselfInfoURL = serverLocation+"user/self/overview/"

let selfPostedURL = serverLocation+"user/self/posted/"
let selfSoldURL = serverLocation+"user/self/sold/"
let selfBoughtURL = serverLocation+"user/self/bought/"
let userOverviewURL = serverLocation+"user/overview/"
let userPostedURL = serverLocation+"user/posted/"
let userModifyURL = serverLocation+"user/update/"
let postAPNSTokenURL = serverLocation+"APNSToken/"

let sendChatURL = serverLocation+"chat/sendmessage/"