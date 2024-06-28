#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint audio_session.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'audio_session'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for managing audio sessions on iOS and tvOS.'
  s.description      = <<-DESC
A Flutter plugin that provides audio session configuration and management for iOS and tvOS platforms.
                       DESC
  s.homepage         = 'https://github.com/yourusername/audio_session'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platforms = { :ios => '12.0', :tvos => '12.0' }
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'

  s.ios.framework = 'AVFoundation'
  s.tvos.framework = 'AVFoundation'
end
