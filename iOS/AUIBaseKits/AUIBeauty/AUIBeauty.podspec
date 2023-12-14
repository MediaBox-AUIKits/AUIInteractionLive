#
# Be sure to run `pod lib lint AUIBeauty.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIBeauty'
  s.version          = '6.7.0'
  s.summary          = 'A short description of AUIBeauty.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS.git', :tag =>"v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.default_subspec = 'Common'
  
  s.subspec 'Common' do |ss|
    ss.vendored_frameworks = 'AliyunQueenUIKit.framework'
    ss.source_files = 'Source/**/*.{h,m,mm}'
  end
  
  s.subspec 'Pro' do |ss|
    ss.dependency 'AUIBeauty/Common'
    ss.resource = 'Resource/Pro/queen_res.bundle'
    ss.pod_target_xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 ENABLE_QUEEN_PRO ENABLE_QUEEN'}
  end
  
  s.subspec 'Lite' do |ss|
    ss.dependency 'AUIBeauty/Common'
    ss.resource = 'Resource/Lite/queen_res.bundle'
    ss.pod_target_xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 ENABLE_QUEEN'}
  end

  s.subspec 'Queen' do |ss|
    ss.dependency 'Queen', '6.7.0-official-pro'
    ss.dependency 'AUIBeauty/Pro'
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'AliVCSDK_Standard'
    ss.dependency 'AUIBeauty/Lite'
  end
  
  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.dependency 'AliVCSDK_InteractiveLive'
    ss.dependency 'AUIBeauty/Lite'
  end
  
  s.subspec 'AliVCSDK_UGC' do |ss|
    ss.dependency 'AliVCSDK_UGC'
    ss.dependency 'AUIBeauty/Lite'
  end
  
  s.subspec 'AliVCSDK_BasicLive' do |ss|
    ss.dependency 'AliVCSDK_BasicLive'
    ss.dependency 'AUIBeauty/Lite'
  end

end
