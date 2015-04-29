Pod::Spec.new do |s|
  s.name     = 'PCFData'
  s.version  = '1.1.0'
  s.license  = { :type => 'CUSTOM', :file => 'LICENSE' }
  s.summary  = 'PCF Mobile Services Data Client SDK for iOS'
  s.homepage = 'https://github.com/cfmobile'
  s.authors  = 'Joshua Winters, Devin Fallak, Andrew Wright'
  s.source   = { :git => 'https://github.com/cfmobile/data-ios.git', :tag => "1.1.0" }
  s.requires_arc = true

  s.ios.deployment_target = '7.0'

  s.public_header_files = 'PCFData/**/*.h'
  s.source_files = 'PCFData/**/*.{h,m}'
end
