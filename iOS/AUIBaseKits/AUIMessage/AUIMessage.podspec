#
# Be sure to run `pod lib lint AUIMessage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIMessage'
  s.version          = '2.0.0'
  s.summary          = 'A short description of AUIMessage.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/aliyunvideo/AUIMessage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/AUIMessage.git', :tag =>"v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.default_subspec = 'Common'
  
  s.subspec 'Common' do |ss|
    ss.source_files = 'Source/Common/*.{h,m,mm}'
  end
  
  s.subspec 'AliVCIM' do |ss|
    ss.dependency 'AliVCInteractionMessage', '1.0.0'
    ss.dependency 'AUIMessage/Common'
    ss.source_files = 'Source/AliVCIM/*.{h,m,mm}'
  end
  
  s.subspec 'AliVCIMCompat' do |ss|
    ss.dependency 'AliVCInteractionMessage', '1.0.0'
    ss.dependency 'AlivcInteraction', '1.2.1'
    ss.dependency 'AUIMessage/Common'
    ss.source_files = 'Source/AliVCIMCompat/*.{h,m,mm}'
  end

  s.subspec 'Alivc' do |ss|
    ss.dependency 'AlivcInteraction', '1.2.1'
    ss.dependency 'AUIMessage/Common'
    ss.source_files = 'Source/Alivc/*.{h,m,mm}'
  end
  
  s.subspec 'RC' do |ss|
    ss.dependency 'RongCloudIM/IMLib', '5.4.5'
    ss.dependency 'AUIMessage/Common'
    ss.source_files = 'Source/RC/*.{h,m,mm}'
  end

end
