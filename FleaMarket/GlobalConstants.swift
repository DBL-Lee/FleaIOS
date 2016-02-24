import AWSCore

let GLOBAL_MAXIMUMPHOTO = 8
let GLOBAL_DESCRIPTIONMAXCHAR = 140

let CognitoRegionType = AWSRegionType.EUWest1
let DefaultServiceRegionType = AWSRegionType.EUWest1
let CognitoIdentityPoolId = "eu-west-1:32e7790b-bcc2-47f4-9386-222ccf14ce0f"
let S3BucketName = "flea.images"

let THUMBNAILSIZE:CGSize = CGSize(width: 128, height: 128)

//image uuid to remove when terminating app
var GLOBAL_imagesUUID:[String] = []

let LocalUploadDirectory:NSURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload")
let LocalDownloadDirectory:NSURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download")