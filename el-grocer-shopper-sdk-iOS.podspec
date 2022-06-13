#
# Be sure to run `pod lib lint el-grocer-shopper-sdk-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'el-grocer-shopper-sdk-iOS'
  s.version          = '0.1.1'
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

  s.source_files = 'el-grocer-shopper-sdk-iOS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'el-grocer-shopper-sdk-iOS' => ['el-grocer-shopper-sdk-iOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
