Pod::Spec.new do |s|
  s.name     = 'MSSData'
  s.version  = '1.0.0'
  s.license  = { :type => 'CUSTOM', :file => 'LICENSE' }
  s.summary  = 'A OpenID Connect client framework for iOS.'
  s.homepage = 'https://github.com/cfmobile'
  s.authors  = 'Rob Szumlakowski'
  s.source   = { :git => 'git@github.com:cfmobile/data-ios', :tag => "1.0.0" }
  s.requires_arc = true
  s.frameworks = 'SystemConfiguration', 'MobileCoreServices'

  s.ios.deployment_target = '6.0'

  s.public_header_files = 'MSSData/**/*.h'
  s.source_files = 'MSSData/**/*.{h,m}'
end
