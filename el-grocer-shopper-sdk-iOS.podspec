#
# Be sure to run `pod lib lint el-grocer-shopper-sdk-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'el-grocer-shopper-sdk-iOS'
  s.version          = '0.1.0'
  s.summary          = 'A short description of el-grocer-shopper-sdk-iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/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/el-grocer-shopper-sdk-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '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' => 'abubaker@elgrocer.com' }
  s.source           = { :git => 'https://github.com/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/el-grocer-shopper-sdk-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'el-grocer-shopper-sdk-iOS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'el-grocer-shopper-sdk-iOS' => ['el-grocer-shopper-sdk-iOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
