#
# Be sure to run `pod lib lint el-grocer-shopper-sdk-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'el-grocer-shopper-sdk-iOS'
  s.version          = '0.1.2'
  s.summary          = 'IOS Shopper app basic setUp.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
'IOS Shopper app basic setUp. This sdk will allow all Shopper app functionalities from sdk. That will be signIn, registration, Store visibilty, Add Product, Place Order, Order Detail, Recipes, Search & locations'
                        DESC

  s.homepage         = 'https://www.elgrocer.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ABM' => 'abubaker@elgrocer.com' }
  s.source           = { :git => 'https://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@github.com/elgrocer/el-grocer-shopper-sdk-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_versions = '4.2'

  s.source_files = 'el-grocer-shopper-sdk-iOS/**/*.{h,m,swift}'
  
  s.resource_bundles = {
      'el-grocer-shopper-sdk-iOS' => ['el-grocer-shopper-sdk-iOS/**/*{.png,.xcassets}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'CoreData'
  
  s.dependency 'AFNetworking' #, '~> 4.0'
  
  s.dependency 'MSPeekCollectionViewDelegateImplementation'
  s.dependency 'GoogleAnalytics'
  s.dependency 'GoogleIDFASupport'
  s.dependency 'GoogleMaps'
  s.dependency 'GooglePlaces'
  s.dependency 'FlagPhoneNumber', '~> 0.7.6'
  s.dependency 'PinCodeTextField'

  # Add the pod for Firebase Crashlytics
  s.dependency 'Firebase/Crashlytics'
  s.dependency 'Crashlytics' # please dont delete this for now it will causing crashes need fixes
  # Recommended: Add the Firebase pod for Google Analytics
  s.dependency 'Firebase/Analytics'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Messaging'
  s.dependency 'Firebase/DynamicLinks'
  s.dependency 'Firebase/Performance'
  s.dependency 'Firebase/Storage'
  s.dependency 'Firebase/Database'
  
  # pod 'AFNetworking', '~> 3.2.1' , :subspecs => [‘Reachability', 'Serialization', 'Security', 'NSURLSession']
  # pod 'AFNetworkActivityLogger', git: 'https://github.com/AFNetworking/AFNetworkActivityLogger.git'
  s.dependency 'AFNetworkActivityLogger' #, :git => 'https://github.com/ToshMeston/AFNetworkActivityLogger.git'

  # pod 'mopub-ios-sdk' #, '~>4.6.0'
  s.dependency 'FBSDKCoreKit'
  # pod 'MaterialShowcase'
    s.dependency 'AppsFlyerFramework'
    s.dependency 'SwiftDate'
    s.dependency 'CleverTap-iOS-SDK'
    s.dependency 'Storyly', '~> 1.19.3'
    s.dependency 'CHDropDownTextField', '~> 1.0.0'
    s.dependency 'FXPageControl'
    s.dependency 'RxSwift' #, '~>4.0'
    s.dependency 'RxCocoa' #,‘~>4.0'
    s.dependency 'HMSegmentedControl'
    s.dependency 'KLCPopup', '~> 1.0'
    s.dependency 'JDFTooltips', '~> 1.1'
    
    
    s.dependency 'DoneCancelNumberPadToolbar', '~> 0.6'
    s.dependency 'BBBadgeBarButtonItem', '~> 1.2'
    s.dependency 'PageControl', '~> 1.0'
    s.dependency 'Shimmer', '~> 1.0'
    s.dependency 'BetterSegmentedControl'
    s.dependency 'AlgoliaSearchClient', '~> 8.0'
    s.dependency 'InstantSearch/Insights', '~> 7.7'
    s.dependency 'STPopup'
    s.dependency 'MaterialComponents/BottomSheet'
    s.dependency 'MaterialComponents/ActivityIndicator'
    s.dependency 'AnimatedGradientView'
    s.dependency 'SkyFloatingLabelTextField', '~> 3.0'
    s.dependency 'IQKeyboardManagerSwift', '6.3.0'
    
    s.dependency 'CCValidator'
      s.dependency 'BadgeControl'
      s.dependency 'DisplaySwitcher' #, '~> 2.0'
      s.dependency 'PMAlertController'
      s.dependency 'SwiftMessages'

      s.dependency 'GrowingTextView', '0.6.1'
      s.dependency 'KAPinField'
      s.dependency 'NBBottomSheet'

      # Pods for RateView
      s.dependency 'FloatRatingView', '~> 4'
      # sendBird chat
      s.dependency 'SendBirdUIKit'
      s.dependency 'SendBirdDesk'
      # add file
      s.dependency 'Adyen'
end
