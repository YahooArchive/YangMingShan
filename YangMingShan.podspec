Pod::Spec.new do |s|
  s.name         = 'YangMingShan'
  s.author       = { "Team" => "yang-ming-shan@oath.com" }
  s.version      = '2.0.1'
  s.summary      = 'The collection of useful UI components that inspired by Yahoo apps.'
  s.homepage     = 'https://github.com/yahoo/YangMingShan'
  s.license      = "Yahoo! Inc. BSD license"
  s.source       = { :git => 'https://github.com/yahoo/YangMingShan.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.frameworks   = ['Foundation', 'UIKit', 'QuartzCore']
  s.platform     = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.default_subspec = 'YMSPhotoPicker'

  s.subspec 'YMSPhotoPicker' do |ss|
    ss.source_files = 'YangMingShan/YMSPhotoPicker/**/*.{h,m}'
    ss.resources    = ['YangMingShan/YMSPhotoPicker/**/*.xib', 'YangMingShan/YMSPhotoPicker/YMSPhotoPickerAssets.xcassets']
    ss.frameworks   = ['Photos', 'AVFoundation']
  end

end
