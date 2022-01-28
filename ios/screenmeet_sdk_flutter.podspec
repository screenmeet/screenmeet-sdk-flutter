#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sdk_live_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'screenmeet_sdk_flutter'
  s.version          = '2.0.9'
  s.summary          = 'A Flutter plugin for a ScreenMeet SDK'
  s.description      = <<-DESC
A Flutter plugin for a ScreenMeet SDK
                       DESC
  s.homepage         = 'http://www.screenmeet.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ScreenMeet, Inc.' => 'emok@screenmeet.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ScreenMeetSDK', '2.0.9'
  s.dependency 'Libyuv', '1703'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
