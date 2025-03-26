
Pod::Spec.new do |s|
  s.name             = 'TUIPlayerCore'
  s.version          = '1.3.0'
  s.summary          = 'TUIPlayerCore SDK.'
  s.description      = <<-DESC
  TUIPlayerCore SDK.
                       DESC

  s.homepage         = 'https://github.com/LiteAVSDK/Player_iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'tencent video cloud'
  s.source           = { :git => '', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.libraries = 'sqlite3', 'z'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.vendored_frameworks = 'SDKProduct/TUIPlayerCore.xcframework'
  s.dependency 'TXLiteAVSDK_Professional'
  s.resource = 'SDKProduct/TUIPlayerCore.xcframework/TUIPlayerCore-Privacy.bundle'
end
