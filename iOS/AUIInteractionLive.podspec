#
# Be sure to run `pod lib lint AUIInteractionLive.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIInteractionLive'
  s.version          = '2.0.0'
  s.summary          = 'A short description of AUIInteractionLive.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/aliyunvideo/AUIInteractionLive_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/AUIInteractionLive_iOS', :tag =>"v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.default_subspecs='AliVCSDK_PremiumLive'
  s.pod_target_xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1'}

  s.subspec 'Live' do |ss|
    ss.resource = 'Resources/*.bundle'
    ss.source_files = 'Source/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'AUIMessage/Alivc'
    ss.dependency 'Masonry'
    ss.dependency 'MJRefresh'
    ss.dependency 'SDWebImage'
  end

  s.subspec 'AliVCSDK_Premium' do |ss|
    ss.dependency 'AUIInteractionLive/Live'
    ss.dependency 'AliVCSDK_Premium'
    ss.dependency 'AUIBeauty/AliVCSDK_Premium'
  end

  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.dependency 'AUIInteractionLive/Live'
    ss.dependency 'AliVCSDK_InteractiveLive'
    ss.dependency 'AUIBeauty/Queen'
  end

  s.subspec 'AliVCSDK_PremiumLive' do |ss|
    ss.dependency 'AUIInteractionLive/Live'
    ss.dependency 'AliVCSDK_PremiumLive'
    ss.dependency 'AUIBeauty/AliVCSDK_PremiumLive'
  end

end
