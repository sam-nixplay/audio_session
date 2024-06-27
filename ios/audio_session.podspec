Pod::Spec.new do |s|
  s.name             = 'audio_session'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Add tvOS platform support
  s.tvos.deployment_target = '10.0'

  # Flutter.framework does not contain an i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }

  # Add tvOS-specific source exclusion
  s.exclude_files = 'Classes/tvos/**/*' if ENV['PLATFORM_NAME'] == 'tvos'

  # Additional settings for tvOS
  s.pod_target_xcconfig['TVOS_DEPLOYMENT_TARGET'] = '10.0' if ENV['PLATFORM_NAME'] == 'tvos'
end
