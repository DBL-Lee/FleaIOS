# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
source 'https://github.com/CocoaPods/Specs'

use_frameworks!

target 'FleaMarket' do
 pod "FastttCamera"
 pod "UITextView+Placeholder"
 pod 'AWSCore'
 pod 'AWSS3'
 pod 'AWSCognito'
 pod 'Alamofire'
 pod 'KDCircularProgress'
 pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
 pod 'SimpleKeychain'
 pod 'JSQMessagesViewController'
 pod 'TOCropViewController'
 pod 'MBProgressHUD'
 pod 'MJRefresh'
 pod 'DZNEmptyDataSet'
 pod 'HyphenateSDK'
end

target 'FleaMarketTests' do

end

target 'FleaMarketUITests' do

end
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
