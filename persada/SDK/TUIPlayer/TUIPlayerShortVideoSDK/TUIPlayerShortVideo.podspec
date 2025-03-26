
Pod::Spec.new do |s|
  s.name             = 'TUIPlayerShortVideo'
  s.version          = '0.0.1'
  s.summary          = 'TUIPlayer短视频SDK.'
  s.description      = <<-DESC
  TUIPlayer短视频SDK.
                       DESC

  s.homepage         = 'https://github.com/LiteAVSDK/Player_iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'tencent video cloud'
  s.source           = { :git => '', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.libraries = 'sqlite3', 'z'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.resource = 'TUIPlayerShortVideo.bundle'
  s.vendored_frameworks = 'SDKProduct/TUIPlayerShortVideo.xcframework'
  s.resource = 'SDKProduct/TUIPlayerShortVideo.xcframework/TUIPlayerShortVideo-Privacy.bundle'
  s.dependency 'TUIPlayerCore'
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'

end
