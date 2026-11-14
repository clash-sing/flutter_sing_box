#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sing_box.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sing_box'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin project for sing-box.'
  s.description      = <<-DESC
A Flutter plugin project for sing-box.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_sing_box/Sources/flutter_sing_box/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # 隐私清单同时供 CocoaPods 与 SwiftPM 使用
  s.resource_bundles = {
    'flutter_sing_box_privacy' => [
      'flutter_sing_box/Sources/flutter_sing_box/PrivacyInfo.xcprivacy'
    ]
  }
end
