Pod::Spec.new do |spec|
  spec.name         = 'TXLiteAVSDK_Professional'
  spec.version      = '11.4.15675'
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.license      = { :type => 'Proprietary',
			:text => <<-LICENSE
				copyright 2017 tencent Ltd. All rights reserved.
				LICENSE
			 }
  spec.homepage     = 'https://cloud.tencent.com/product/trtc'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/647/32173'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXLiteAVSDK for Professional Edition.'
  spec.ios.framework = ['AVFoundation', 'AVKit', 'Accelerate', 'AssetsLibrary', 'MetalKit', 'SystemConfiguration', 'GLKit', 'CoreServices', 'ReplayKit', 'AudioToolbox', 'VideoToolbox', 'CoreMotion', 'MetalPerformanceShaders']
  spec.library = 'c++', 'resolv', 'sqlite3', 'z'
  spec.requires_arc = true
  
  spec.source = { :path => './SDK/TXLiteAVSDK_Professional/TXLiteAVSDK_Professional/' }
  spec.default_subspec = 'Professional'
  
  spec.subspec 'Professional' do |professional|
    professional.preserve_paths = 'TXLiteAVSDK_Professional/TXLiteAVSDK_Professional.xcframework'
    professional.source_files = 'TXLiteAVSDK_Professional/TXLiteAVSDK_Professional.xcframework/ios-arm64_armv7/TXLiteAVSDK_Professional.framework/Headers/*.h'
    professional.public_header_files = 'TXLiteAVSDK_Professional/TXLiteAVSDK_Professional.xcframework/ios-arm64_armv7/TXLiteAVSDK_Professional.framework/Headers/*.h'
    professional.vendored_frameworks = 'TXLiteAVSDK_Professional/TXLiteAVSDK_Professional.xcframework', 'TXLiteAVSDK_Professional/TXSoundTouch.xcframework', 'TXLiteAVSDK_Professional/TXFFmpeg.xcframework'
    # 添加 resources 属性
    professional.resources = 'TXLiteAVSDK_Professional/TXLiteAVSDK_Professional.xcframework/ios-arm64_armv7/TXLiteAVSDK_Professional.framework/*.bundle'
    professional.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXLiteAVSDK_Professional/TXLiteAVSDK_Professional/TXLiteAVSDK_Professional.xcframework/ios-arm64_armv7/TXLiteAVSDK_Professional.framework/Headers/'}
  end

  spec.subspec 'ReplayKitExt' do |replaykit|
    replaykit.ios.deployment_target = '10.0'
    replaykit.preserve_paths = 'TXLiteAVSDK_Professional/TXLiteAVSDK_ReplayKitExt.xcframework'
    replaykit.source_files = 'TXLiteAVSDK_Professional/TXLiteAVSDK_ReplayKitExt.xcframework/ios-arm64_armv7/TXLiteAVSDK_ReplayKitExt.framework/Headers/*.h'
    replaykit.public_header_files = 'TXLiteAVSDK_Professional/TXLiteAVSDK_ReplayKitExt.xcframework/ios-arm64_armv7/TXLiteAVSDK_ReplayKitExt.framework/Headers/*.h'
    replaykit.vendored_frameworks = 'TXLiteAVSDK_Professional/TXLiteAVSDK_ReplayKitExt.xcframework'
    replaykit.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXLiteAVSDK_Professional/TXLiteAVSDK_Professional/TXLiteAVSDK_ReplayKitExt.xcframework/ios-arm64_armv7/TXLiteAVSDK_ReplayKitExt.framework/Headers/'}
  end
end
