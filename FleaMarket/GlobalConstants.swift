import AWSCore

let GLOBAL_MAXIMUMPHOTO = 8
let GLOBAL_DESCRIPTIONMAXCHAR = 140

let CognitoRegionType = AWSRegionType.EUWest1
let DefaultServiceRegionType = AWSRegionType.EUWest1
let CognitoIdentityPoolId = "eu-west-1:32e7790b-bcc2-47f4-9386-222ccf14ce0f"
let S3ImagesBucketName = "flea.images"
let S3AvatarsBucketName = "flea.avatars"
let S3IconBucketName = "flea.icons"

let connectionFailureString = "网络连接有问题，请检查是否连接上了网络"

let THUMBNAILSIZE:CGSize = CGSize(width: 128, height: 128)

//image uuid to remove when terminating app
var GLOBAL_imagesUUID:[String] = []

let AppDirectory:AnyObject = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray)[0]
let LocalUploadDirectory:NSURL = NSURL(fileURLWithPath: AppDirectory.stringByAppendingPathComponent("upload"))
let LocalDownloadDirectory = NSURL(fileURLWithPath: AppDirectory.stringByAppendingPathComponent("download"))
let LocalIconDirectory = NSURL(fileURLWithPath: AppDirectory.stringByAppendingPathComponent("icon"))


let NetworkProblemString = "网络有问题,请检查网络或稍后再试"
