//
//  constantURLs.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 11/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import Foundation

let serverLocation = "http://192.168.0.133:8000/"

let getProductURL = serverLocation+"products/"
let orderProductURL = serverLocation+"products/order/"
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
let selfOrderedURL = serverLocation+"user/self/ordered/"
let selfPendingBuyURL = serverLocation+"user/self/pendingbuy/"
let selfPendingSellURL = serverLocation+"user/self/pendingsell/"
let selfAwaitingURL = serverLocation+"user/self/awaiting/"
let selfAwaitingPeopleURL = serverLocation+"user/self/awaitingpeople/"

let changeOrderAmtURL = serverLocation+"products/changeorder/"
let cancelOrderURL = serverLocation+"products/cancelorder/"
let acceptBuyRequestURL = serverLocation+"products/buy/"
let confirmGetProductURL = serverLocation+"products/finish/"
let postFeedbackURL = serverLocation+"products/feedback/"

let userOverviewURL = serverLocation+"user/overview/"
let userPostedURL = serverLocation+"user/posted/"
let userModifyURL = serverLocation+"user/update/"


let postAPNSTokenURL = serverLocation+"APNSToken/"

let sendChatURL = serverLocation+"chat/sendmessage/"