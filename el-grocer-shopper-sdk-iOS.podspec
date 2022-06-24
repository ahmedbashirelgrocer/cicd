#
#  Be sure to run `pod spec lint el-grocer-shopper-sdk-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    


  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name             = 'el-grocer-shopper-sdk-iOS'
  s.version          = '0.1.12'
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

  

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.ios.deployment_target = '12.0'
  s.swift_versions = '4.2'

  s.source_files = 'el-grocer-shopper-sdk-iOS/Classes/**/*.{m,h,swift}'
  s.exclude_files = "Classes/Exclude"
   
  s.resource_bundles = {
      'el-grocer-shopper-sdk-iOS' => ['el-grocer-shopper-sdk-iOS/**/{R-SupportingFiles/*.*,*.storyboard,*.xib,*.xcassets,*.xcdatamodeld,*.m4r,*.otf,*.ttf,*.json,*.strings}']
  }
  
  #.{png,xcassets,xcdatamodeld,plist,strings,json,m4r}

    # spec.public_header_files = "Classes/**/*.h"
  # s.public_header_files = 'Pod/Classes/**/*.h'
  
  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  #s.xcconfig = { 'SWIFT_OBJC_BRIDGING_HEADER' => 'el-grocer-shopper-sdk-iOS/Bridging-Header.h' }
  
  s.frameworks = 'UIKit', 'Foundation', 'CoreData', 'AdSupport', 'AppTrackingTransparency', 'SystemConfiguration'
  
 # s.dependency 'AFNetworking' , '~> 4.0'
  
  s.dependency 'MSPeekCollectionViewDelegateImplementation'
 
  #s.dependency 'FlagPhoneNumber', '~> 0.7.6'
  s.dependency 'libPhoneNumber-iOS'
  s.dependency 'PinCodeTextField' ###

  # Add the pod for Firebase Crashlytics
  s.dependency 'Firebase/Crashlytics'
  #s.dependency 'Crashlytics' # please dont delete this for now it will causing crashes need fixes
  # Recommended: Add the Firebase pod for Google Analytics
  # s.dependency 'Firebase/Analytics', '~> 7.5.0'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase/Core', '~> 7.5.0'
  s.dependency 'Firebase/Messaging'
  s.dependency 'Firebase/DynamicLinks'
  s.dependency 'Firebase/Performance'
  # s.dependency 'Firebase/Storage'
  # s.dependency 'Firebase/Database'
  # s.dependency 'Firebase'
  #s.dependency GoogleConversionTracking
  
  # pod 'AFNetworking', '~> 3.2.1' , :subspecs => [‘Reachability', 'Serialization', 'Security', 'NSURLSession']
  # pod 'AFNetworkActivityLogger', git: 'https://github.com/AFNetworking/AFNetworkActivityLogger.git'
  # s.dependency 'AFNetworkActivityLogger' #, :git => 'https://github.com/ToshMeston/AFNetworkActivityLogger.git'

  # pod 'mopub-ios-sdk' #, '~>4.6.0'
  s.dependency 'FBSDKCoreKit', '~> 12.3.1'
  # pod 'MaterialShowcase'
  #s.dependency 'AppsFlyerFramework'
  s.dependency 'SwiftDate'
  s.dependency 'CleverTap-iOS-SDK'
  s.dependency 'Storyly', '~> 1.19.3'
  s.dependency 'CHDropDownTextField', '~> 1.0.0'
  s.dependency 'FXPageControl'
  s.dependency 'RxSwift', '~>5.1.1'
  s.dependency 'RxCocoa', '~>5.1.1'
  s.dependency 'HMSegmentedControl'
  s.dependency 'KLCPopup', '~> 1.0'
  s.dependency 'JDFTooltips', '~> 1.1'
    
  s.dependency 'DoneCancelNumberPadToolbar', '~> 0.6'
  #s.dependency 'BBBadgeBarButtonItem', '~> 1.2'
  #s.dependency 'PageControl' #, '~> 1.0'
  s.dependency 'Shimmer', '~> 1.0'
  s.dependency 'BetterSegmentedControl'
  s.dependency 'AlgoliaSearchClient', '~> 8.0'
  s.dependency 'InstantSearch/Insights', '~> 7.7'
  s.dependency 'STPopup'
  s.dependency 'MaterialComponents/BottomSheet'
  s.dependency 'MaterialComponents/ActivityIndicator'
  s.dependency 'AnimatedGradientView'
  s.dependency 'SkyFloatingLabelTextField', '~> 3.0'
  s.dependency 'IQKeyboardManagerSwift'#, '6.3.0'
    
  s.dependency 'CCValidator'
  s.dependency 'BadgeControl'
  s.dependency 'DisplaySwitcher' #, '~> 2.0'
  #s.dependency 'PMAlertController' ###
  s.dependency 'SwiftMessages'

  s.dependency 'GrowingTextView'#, '0.6.1'
  #s.dependency 'KAPinField' ###
  s.dependency 'NBBottomSheet'

      # Pods for RateView
  s.dependency 'FloatRatingView', '~> 4'
      # sendBird chat
  s.dependency 'SendBirdUIKit'
  s.dependency 'SendBirdDesk'
      # add file
  s.dependency 'Adyen'
  
  s.dependency 'SDWebImage'
  
  s.static_framework   = true
  #s.dependency 'GoogleAnalytics'
  #s.dependency 'GoogleIDFASupport'
  s.dependency 'GoogleMaps'
  s.dependency 'GooglePlaces'
#s.dependency 'AppsFlyerFramework'


end
